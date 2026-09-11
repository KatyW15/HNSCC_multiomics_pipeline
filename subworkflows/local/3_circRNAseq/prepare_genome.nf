// PREPARE_GENOME (circRNA arm) — build the per-aligner indices and the
// annotation assets the CIRCRNASEQ ensemble needs, once, cached by -resume.
// See pipeline_architecture.md §3 `CIRCRNASEQ` and the "genome / index prep"
// note in the first circRNA outline.
//
// Each index can be supplied prebuilt via params (params.star_index,
// params.bwa_index, params.bowtie2_index, params.ciriquant_index) to skip the
// build; otherwise it is generated from params.fasta / params.gtf here.
//
// Every emitted reference is a value channel (`.first()`), so downstream
// processes reuse it across all samples rather than consuming it once.

include { STAR_GENOMEGENERATE     } from '../../../modules/local/circrna/star_genomegenerate'
include { BWA_INDEX               } from '../../../modules/local/circrna/bwa_index'
include { BOWTIE2_BUILD           } from '../../../modules/local/circrna/bowtie2_build'
include { CIRIQUANT_INDEX         } from '../../../modules/local/circrna/ciriquant_index'
include { SAMTOOLS_FAIDX          } from '../../../modules/local/circrna/samtools_faidx'
include { CIRCRNA_ANNOTATION_PREP } from '../../../modules/local/circrna/circrna_annotation_prep'

workflow PREPARE_GENOME {
    take:
    fasta_path      // string — hg38 primary assembly (GENCODE-distributed)
    gtf_path        // string — GENCODE v50 annotation
    circatlas_path  // string — pinned circAtlas hg38 release (params.circrna_annotation)

    main:
    ch_fasta     = Channel.value(file(fasta_path,     checkIfExists: true))
    ch_gtf       = Channel.value(file(gtf_path,       checkIfExists: true))
    ch_circatlas = Channel.value(file(circatlas_path, checkIfExists: true))

    // --- .fai (needed by CIRI2/CIRIquant and the consensus motif check) ---
    SAMTOOLS_FAIDX(ch_fasta)

    // --- STAR index (CIRCexplorer2 + shared chimeric alignment) ---
    if (params.star_index) {
        ch_star_index = Channel.value(file(params.star_index, checkIfExists: true))
    } else {
        STAR_GENOMEGENERATE(ch_fasta, ch_gtf)
        ch_star_index = STAR_GENOMEGENERATE.out.index.first()
    }

    // --- BWA index (CIRIquant -> CIRI2) ---
    if (params.bwa_index) {
        ch_bwa_index = Channel.value(file(params.bwa_index, checkIfExists: true))
    } else {
        BWA_INDEX(ch_fasta)
        ch_bwa_index = BWA_INDEX.out.index.first()
    }

    // --- Bowtie2 index (find_circ) ---
    if (params.bowtie2_index) {
        ch_bowtie2_index = Channel.value(file(params.bowtie2_index, checkIfExists: true))
    } else {
        BOWTIE2_BUILD(ch_fasta)
        ch_bowtie2_index = BOWTIE2_BUILD.out.index.first()
    }

    // --- CIRIquant reference bundle (its config.yaml + hisat2 index) ---
    if (params.ciriquant_index) {
        ch_ciriquant_index = Channel.value(file(params.ciriquant_index, checkIfExists: true))
    } else {
        CIRIQUANT_INDEX(ch_fasta, ch_gtf, ch_bwa_index)
        ch_ciriquant_index = CIRIQUANT_INDEX.out.bundle.first()
    }

    // --- circAtlas hg38 -> normalised known-circRNA BED + annotation GTF on
    //     the chr-prefixed contig convention (open item #11) ---
    CIRCRNA_ANNOTATION_PREP(ch_circatlas, ch_gtf)

    emit:
    fasta           = ch_fasta
    fai             = SAMTOOLS_FAIDX.out.fai.first()
    gtf             = ch_gtf
    star_index      = ch_star_index
    bwa_index       = ch_bwa_index
    bowtie2_index   = ch_bowtie2_index
    ciriquant_index = ch_ciriquant_index
    known_circ_bed  = CIRCRNA_ANNOTATION_PREP.out.known_circ_bed.first()
    annotation_gtf  = CIRCRNA_ANNOTATION_PREP.out.circ_annotation.first()
}
