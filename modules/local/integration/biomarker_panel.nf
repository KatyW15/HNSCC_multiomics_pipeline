// INTEGRATION_BIOMARKER — candidate circRNA biomarker panel. See
// pipeline_architecture.md §3, analysis_questions_master_list.md
// (Supporting / Mechanistic — Biomarker panel / classifier), and
// bin/biomarker_panel.R.
//
// Feature space = high-confidence circRNA set (consensus tier + passes the
// minimum-expression gate), optionally + top miRNA. Tasks: tumour vs normal;
// HPV+ vs HPV-. Nested CV (outer LOOCV or repeated 5-fold; inner for feature
// selection / hyperparameters), glmnet elastic net and/or random forest +
// stability selection. Report AUC with CI and per-fold selected-feature
// frequency. Strictly hypothesis-generating at n≈30 — labelled as such.
//
// TODO: real logic lives in bin/biomarker_panel.R — this process is a scaffold.

process INTEGRATION_BIOMARKER {
    label 'process_medium'
    container 'PLACEHOLDER/bioconductor-integration'   // glmnet, randomForest, pROC

    publishDir "${params.outdir}/integration/biomarker", mode: 'copy'

    input:
    path mae
    path circrna_de, stageAs: 'circrna_de/*'

    output:
    path 'biomarker/*.tsv', emit: panel

    script:
    """
    # TODO: not implemented — see bin/biomarker_panel.R
    mkdir -p biomarker
    biomarker_panel.R \\
        --mae ${mae} \\
        --circrna-de-dir circrna_de \\
        --outdir biomarker
    """

    stub:
    """
    mkdir -p biomarker
    touch biomarker/tumour_vs_normal_panel.tsv \\
          biomarker/hpv_pos_vs_neg_panel.tsv \\
          biomarker/cv_performance.tsv
    """
}
