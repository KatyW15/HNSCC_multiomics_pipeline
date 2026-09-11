// INTEGRATION_RECURRENCE — recurrence / "commonality" scoring layered over
// every DE result table (circRNA / miRNA / host-gene). See
// pipeline_architecture.md §3, analysis_questions_master_list.md
// (Cross-Cutting Methodological Notes), and bin/recurrence_score.R.
//
// Pure bookkeeping, no model: per-patient paired log2FC (tumour vs its own
// normal) for each feature, then the fraction of patients concordant with the
// cohort call. Emits each DE table re-written with n_patients_concordant,
// frac_concordant, commonality_tier columns.
//
// TODO: real logic lives in bin/recurrence_score.R — this process is a scaffold.

process INTEGRATION_RECURRENCE {
    label 'process_medium'
    container 'PLACEHOLDER/bioconductor-integration'

    publishDir "${params.outdir}/integration/recurrence_scores", mode: 'copy'

    input:
    path mae
    path de_tables, stageAs: 'de_tables/*'

    output:
    path 'recurrence/*.tsv', emit: tables

    script:
    """
    # TODO: not implemented — see bin/recurrence_score.R
    mkdir -p recurrence
    recurrence_score.R \\
        --mae ${mae} \\
        --de-dir de_tables \\
        --outdir recurrence
    """

    stub:
    """
    mkdir -p recurrence
    touch recurrence/circrna_de.recurrence.tsv recurrence/mirna_de.recurrence.tsv
    """
}
