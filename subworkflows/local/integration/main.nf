// INTEGRATION — where most of the master analysis question list actually gets
// answered, downstream of every per-modality subworkflow. See
// pipeline_architecture.md §3 and HNSCC_pipeline_build/analysis_questions_master_list.md.
//
// Design (revised — MOFA+ dropped, see pipeline_architecture.md §3 rationale):
//   Layer 0  INTEGRATION_ASSEMBLE      build one per-patient MultiAssayExperiment
//                                      (missing modalities tolerated via its
//                                      sampleMap, NOT via strict Nextflow joins —
//                                      see pipeline_architecture.md §2 design risk)
//   Modules  INTEGRATION_RECURRENCE    per-patient concordance layer over every DE table
//            MIRNA_TARGET_PREDICT +
//            INTEGRATION_CERNA         circRNA–miRNA(–mRNA) ceRNA network
//            INTEGRATION_GENOMIC       circRNA loci/burden vs CNV/SV/TMB/HPV-integration
//            INTEGRATION_HPV_AXIS      HPV-derived circRNA specificity + E6/E7 load axis
//            INTEGRATION_STRUCTURE     per-modality clustering + iClusterBayes + ARI (Q3)
//            INTEGRATION_BIOMARKER     nested-CV candidate circRNA panel
//            INTEGRATION_CANDIDATE_REGISTRY  cross-module priority table
//
// Everything here is EXPLORATORY / hypothesis-generating at n≈30 tumours;
// confirmatory Q1/Q2 significance stays upstream in the per-modality DESeq2
// models. Real logic lives in bin/*.R — the processes below are scaffolds.
//
// NOTE: this subworkflow is not yet wired into workflows/hnscc_multiomics.nf.

include { INTEGRATION_ASSEMBLE          } from '../../../modules/local/integration/assemble_mae'
include { INTEGRATION_RECURRENCE        } from '../../../modules/local/integration/recurrence_score'
include { MIRNA_TARGET_PREDICT          } from '../../../modules/local/integration/mirna_target_predict'
include { INTEGRATION_CERNA             } from '../../../modules/local/integration/cerna_network'
include { INTEGRATION_GENOMIC           } from '../../../modules/local/integration/genomic_correlation'
include { INTEGRATION_HPV_AXIS          } from '../../../modules/local/integration/hpv_axis'
include { INTEGRATION_STRUCTURE         } from '../../../modules/local/integration/structure_clustering'
include { INTEGRATION_BIOMARKER         } from '../../../modules/local/integration/biomarker_panel'
include { INTEGRATION_CANDIDATE_REGISTRY } from '../../../modules/local/integration/candidate_registry'

workflow INTEGRATION {
    take:
    circrnaseq_out   // CIRCRNASEQ.out      — .calls, .de
    rnaseq_out       // RNASEQ_ADAPTER.out  — .gene_counts (host-gene DE table emit still TODO upstream, open item #17)
    smrnaseq_out     // SMRNASEQ.out        — .de
    wgs_out          // WGS_ADAPTER.out     — .somatic_variants, .cnv_consensus, .sv_calls, .coverage_qc
    hpv_out          // HPV_DETECTION.out   — .linear_quant, .circrna_calls, .integration_sites

    main:

    // Reference / metadata inputs — plain paths become reusable value channels.
    ch_samplesheet = file(params.samplesheet, checkIfExists: true)
    ch_gtf         = file(params.gtf,         checkIfExists: true)
    ch_fasta       = file(params.fasta,       checkIfExists: true)

    // Normalise each per-modality product stream to a reusable value channel
    // (one collected list). Each raw take: sub-channel is read exactly once here.
    ch_circ_calls = circrnaseq_out.calls.collect().ifEmpty([]).first()
    ch_circ_de    = circrnaseq_out.de.collect().ifEmpty([]).first()
    ch_rna_counts = rnaseq_out.gene_counts.collect().ifEmpty([]).first()
    ch_smrna_de   = smrnaseq_out.de.collect().ifEmpty([]).first()
    ch_wgs        = wgs_out.somatic_variants
                        .mix(wgs_out.cnv_consensus, wgs_out.sv_calls, wgs_out.coverage_qc)
                        .collect().ifEmpty([]).first()
    ch_hpv_linear = hpv_out.linear_quant.collect().ifEmpty([]).first()
    ch_hpv_circ   = hpv_out.circrna_calls.collect().ifEmpty([]).first()
    ch_hpv_sites  = hpv_out.integration_sites.collect().ifEmpty([]).first()

    // ---- Layer 0: assemble the per-patient MultiAssayExperiment ------------
    // assemble_mae.R combines these keyed on patient_id, tolerant of absent
    // modalities — see pipeline_architecture.md §2 design risk.
    INTEGRATION_ASSEMBLE(
        ch_samplesheet,
        ch_circ_calls.mix(ch_circ_de).collect(),
        ch_rna_counts,
        ch_smrna_de,
        ch_wgs,
        ch_hpv_linear.mix(ch_hpv_circ, ch_hpv_sites).collect()
    )
    ch_mae = INTEGRATION_ASSEMBLE.out.mae.first()

    // ---- Recurrence / commonality scoring over every DE table -------------
    // TODO open item #17: fold in RNASEQ_ADAPTER's host-gene DESeq2 table once
    // it exists as an emit.
    ch_de_tables = ch_circ_de.mix(ch_smrna_de).collect()
    INTEGRATION_RECURRENCE(ch_mae, ch_de_tables)

    // ---- ceRNA network -------------------------------------------------
    MIRNA_TARGET_PREDICT(ch_mae, ch_circ_calls, ch_gtf, ch_fasta)
    INTEGRATION_CERNA(ch_mae, MIRNA_TARGET_PREDICT.out.pairs)

    // ---- circRNA vs genomic alterations ------------------------------
    INTEGRATION_GENOMIC(ch_mae, ch_gtf)

    // ---- HPV stratification integration layer ----------------------
    INTEGRATION_HPV_AXIS(ch_mae, ch_hpv_circ, ch_samplesheet)

    // ---- Unsupervised multi-omic structure (Q3a/Q3b) ---------------
    INTEGRATION_STRUCTURE(ch_mae)

    // ---- Candidate biomarker panel -------------------------------
    INTEGRATION_BIOMARKER(ch_mae, ch_circ_de)

    // ---- Cross-module candidate registry ----------------------
    ch_recurrence = INTEGRATION_RECURRENCE.out.tables.collect().ifEmpty([]).first()
    ch_cerna      = INTEGRATION_CERNA.out.network.collect().ifEmpty([]).first()
    ch_genomic    = INTEGRATION_GENOMIC.out.results.collect().ifEmpty([]).first()
    ch_hpv_axis   = INTEGRATION_HPV_AXIS.out.results.collect().ifEmpty([]).first()
    ch_structure  = INTEGRATION_STRUCTURE.out.results.collect().ifEmpty([]).first()
    ch_biomarker  = INTEGRATION_BIOMARKER.out.panel.collect().ifEmpty([]).first()

    INTEGRATION_CANDIDATE_REGISTRY(
        ch_recurrence.mix(ch_cerna, ch_genomic, ch_hpv_axis, ch_structure, ch_biomarker).collect()
    )

    emit:
    mae                  = ch_mae
    recurrence_scores    = ch_recurrence
    cerna_network        = ch_cerna
    genomic_correlation  = ch_genomic
    hpv_axis             = ch_hpv_axis
    structure            = ch_structure
    biomarker_candidates = ch_biomarker
    candidate_registry   = INTEGRATION_CANDIDATE_REGISTRY.out.registry
}
