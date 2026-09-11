// CIRCRNASEQ — RNase R-treated circRNA-seq, host genome, primary circRNA
// source. Full spec: pipeline_architecture.md §3 `CIRCRNASEQ` (locked
// 2026-09-03) and open items #1, #20–24.
//
// Scope: the RNase R libraries are the ONLY circRNA-calling input. Total
// RNA-seq contributes STAR chimeric junctions for cross-library co-validation
// only (Q1d). HPV-derived circRNAs are handled in HPV_DETECTION, not here.
//
//   trimmed reads
//        │
//        ├─ STAR (shared: chimeric junctions + gene counts + unmapped) ─┐
//        │        │                                                     │
//        │        └─ CIRCEXPLORER2 ──┐                                   │
//        ├─ CIRIQUANT (BWA→CIRI2, + quantification) ──┐                  │
//        └─ BOWTIE2 → FIND_CIRC ──┐                   │                  │
//                                 ▼                   ▼                  │
//                       CIRCRNA_CONSENSUS  (merge on 5 bp margin,        │
//                        n_tools flag, ≥2 reads, GT/AG advisory)         │
//                                 │                                     │
//                       CIRCRNA_ANNOTATE  (circAtlas known/novel,       │
//                        host gene/exon structure — GENCODE v50)        │
//                                 │                                     │
//              ┌──────────────────┼─────────────────────┐               │
//              ▼                  ▼                     ▼               ▼
//     CIRCRNA_QUANT_MATRIX   CIRCRNA_DESEQ2     CIRCRNA_COVALIDATE   RNASER_QC
//     (CIRIquant counts,     (paired T/N +      (vs RNASEQ_ADAPTER   (RNase R
//      ≥2-tool ∩ CIRIquant)   HPV interaction)   chimeric junctions)  efficiency)
//
// The bespoke steps (consensus, annotation, matrix, DE, co-validation, RNase R
// QC) live in bin/circrna_*.R|py — currently scaffolds, same maturity as the
// INTEGRATION modules.

include { PREPARE_GENOME        } from './prepare_genome'
include { FASTQC                } from '../../../modules/local/circrna/fastqc'
include { TRIMGALORE            } from '../../../modules/local/circrna/trimgalore'
include { STAR_ALIGN_CIRC       } from '../../../modules/local/circrna/star_align'
include { CIRCEXPLORER2         } from '../../../modules/local/circrna/circexplorer2'
include { CIRIQUANT             } from '../../../modules/local/circrna/ciriquant'
include { FIND_CIRC             } from '../../../modules/local/circrna/find_circ'
include { CIRCRNA_CONSENSUS     } from '../../../modules/local/circrna/circrna_consensus'
include { CIRCRNA_ANNOTATE      } from '../../../modules/local/circrna/circrna_annotate'
include { CIRCRNA_QUANT_MATRIX  } from '../../../modules/local/circrna/circrna_quant_matrix'
include { CIRCRNA_DESEQ2        } from '../../../modules/local/circrna/circrna_deseq2'
include { CIRCRNA_COVALIDATE    } from '../../../modules/local/circrna/circrna_covalidate'
include { RNASER_QC             } from '../../../modules/local/circrna/rnaser_qc'

workflow CIRCRNASEQ {
    take:
    samples             // [meta, fastq_1, fastq_2] from INPUT_CHECK.out.circrnaseq
    chimeric_junctions  // [meta, Chimeric.out.junction] from RNASEQ_ADAPTER (co-validation only)

    main:
    ch_multiqc = Channel.empty()

    // ---- references / params -------------------------------------------
    if (!params.fasta)              error "CIRCRNASEQ: --fasta is required"
    if (!params.gtf)                error "CIRCRNASEQ: --gtf is required"
    if (!params.circrna_annotation) error "CIRCRNASEQ: --circrna_annotation is required (pinned circAtlas hg38 release; see pipeline_architecture.md open item #16)"

    def known_tools = ['circexplorer2', 'ciriquant', 'find_circ']
    def tools       = params.circrna_tools.tokenize(',').collect { it.trim() }
    def unknown     = tools - known_tools
    if (unknown)  error "CIRCRNASEQ: unknown --circrna_tools entries ${unknown} (valid: ${known_tools})"
    if (!tools)   error "CIRCRNASEQ: --circrna_tools resolved to an empty list"
    log.info "CIRCRNASEQ: detection ensemble = ${tools.join(', ')}"

    PREPARE_GENOME(params.fasta, params.gtf, params.circrna_annotation)

    // ---- read QC + trimming ------------------------------------------
    // No rRNA/tRNA pre-depletion — libraries were rRNA-depleted pre-seq.
    ch_reads = samples.map { meta, f1, f2 ->
        def files = f2 ? [f1, f2] : [f1]
        [meta, files]
    }
    FASTQC(ch_reads)
    TRIMGALORE(ch_reads)
    ch_trimmed = TRIMGALORE.out.reads
    // .flatten() — paired-end samples emit two zips / two trimming reports each
    ch_multiqc = ch_multiqc
        .mix(FASTQC.out.zip.map { _meta, z -> z }.flatten())
        .mix(TRIMGALORE.out.log.map { _meta, l -> l }.flatten())

    // ---- shared STAR alignment (chimeric-aware) ---------------------
    // One pass feeds CIRCexplorer2, the RNase R QC (gene counts), and the
    // unmapped-read hand-off to HPV_DETECTION.
    STAR_ALIGN_CIRC(
        ch_trimmed,
        PREPARE_GENOME.out.star_index,
        PREPARE_GENOME.out.gtf
    )
    ch_multiqc = ch_multiqc.mix(STAR_ALIGN_CIRC.out.log_final.map { _meta, l -> l })

    // ---- per-tool BSJ detection -----------------------------------
    // Every branch emits [meta, tool, bsj_bed] in a common shape.
    ch_per_tool = Channel.empty()

    if ('circexplorer2' in tools) {
        CIRCEXPLORER2(
            STAR_ALIGN_CIRC.out.chimeric,
            PREPARE_GENOME.out.fasta,
            PREPARE_GENOME.out.annotation_gtf
        )
        ch_per_tool = ch_per_tool.mix(CIRCEXPLORER2.out.bsj.map { meta, bed -> [meta, 'circexplorer2', bed] })
    }

    ch_ciriquant_gtf = Channel.empty()
    if ('ciriquant' in tools) {
        CIRIQUANT(
            ch_trimmed,
            PREPARE_GENOME.out.ciriquant_index
        )
        ch_per_tool     = ch_per_tool.mix(CIRIQUANT.out.bsj.map { meta, bed -> [meta, 'ciriquant', bed] })
        ch_ciriquant_gtf = CIRIQUANT.out.gtf
        ch_multiqc = ch_multiqc.mix(CIRIQUANT.out.log.map { _meta, l -> l })
    } else {
        log.warn "CIRCRNASEQ: ciriquant not in --circrna_tools — CIRCRNA_QUANT_MATRIX/DESEQ2 have no count source and will be skipped"
    }

    if ('find_circ' in tools) {
        // find_circ's canonical single-pass workflow (align -> anchors ->
        // re-align -> find_circ.py -> filters) all in one module.
        FIND_CIRC(
            ch_trimmed,
            PREPARE_GENOME.out.bowtie2_index,
            PREPARE_GENOME.out.fasta
        )
        ch_per_tool = ch_per_tool.mix(FIND_CIRC.out.bsj.map { meta, bed -> [meta, 'find_circ', bed] })
    }

    // ---- consensus / filtering (per sample) -----------------------
    // Group every tool's call set for a sample: [meta, [beds], [tools]].
    ch_grouped = ch_per_tool
        .map { meta, tool, bed -> [meta.id, meta, tool, bed] }
        .groupTuple(by: 0)
        .map { _id, metas, toolset, beds -> [metas[0], beds, toolset] }

    CIRCRNA_CONSENSUS(
        ch_grouped,
        PREPARE_GENOME.out.fasta,
        PREPARE_GENOME.out.fai
    )

    // ---- cohort-level annotation + matrix + DE ------------------
    ch_consensus_all = CIRCRNA_CONSENSUS.out.bsj.map { _meta, tsv -> tsv }.collect()
    ch_samplesheet   = file(params.samplesheet, checkIfExists: true)

    CIRCRNA_ANNOTATE(
        ch_consensus_all,
        PREPARE_GENOME.out.annotation_gtf,
        PREPARE_GENOME.out.known_circ_bed
    )

    ch_de       = Channel.empty()
    ch_counts   = Channel.empty()
    ch_cpm      = Channel.empty()
    ch_ratio    = Channel.empty()
    if ('ciriquant' in tools) {
        CIRCRNA_QUANT_MATRIX(
            ch_ciriquant_gtf.map { _meta, gtf -> gtf }.collect(),
            CIRCRNA_ANNOTATE.out.annotated,
            ch_samplesheet
        )
        ch_counts = CIRCRNA_QUANT_MATRIX.out.bsj_counts
        ch_cpm    = CIRCRNA_QUANT_MATRIX.out.cpm
        ch_ratio  = CIRCRNA_QUANT_MATRIX.out.circ_linear_ratio

        CIRCRNA_DESEQ2(
            CIRCRNA_QUANT_MATRIX.out.bsj_counts,
            CIRCRNA_ANNOTATE.out.annotated,
            ch_samplesheet
        )
        ch_de = CIRCRNA_DESEQ2.out.tables
    }

    // ---- cross-library co-validation (vs total RNA-seq) --------
    CIRCRNA_COVALIDATE(
        CIRCRNA_ANNOTATE.out.annotated,
        chimeric_junctions.map { _meta, j -> j }.collect().ifEmpty([])
    )

    // ---- RNase R efficiency QC --------------------------------
    RNASER_QC(
        STAR_ALIGN_CIRC.out.gene_counts.map { _meta, c -> c }.collect(),
        PREPARE_GENOME.out.gtf,
        ch_samplesheet
    )
    ch_multiqc = ch_multiqc.mix(RNASER_QC.out.mqc)

    emit:
    calls             = CIRCRNA_COVALIDATE.out.table   // annotated consensus + n_tools tier + validated_in_totalRNA
    bsj_counts        = ch_counts                      // circRNA_bsj assay for INTEGRATION_ASSEMBLE
    cpm_counts        = ch_cpm                         // circRNA_cpm assay
    de                = ch_de                          // paired DESeq2 tables
    circ_linear_ratio = ch_ratio
    unmapped          = STAR_ALIGN_CIRC.out.unmapped   // [meta, fastq(s)] -> HPV_DETECTION
    multiqc           = ch_multiqc
}
