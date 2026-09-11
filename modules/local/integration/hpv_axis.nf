// INTEGRATION_HPV_AXIS — HPV stratification integration layer. See
// pipeline_architecture.md §3, analysis_questions_master_list.md (Q2b; supports
// Q2a / Q3b), and bin/hpv_axis.R.
//
// The bulk of HPV+/- DE stays upstream (per-modality DESeq2 with an HPV
// interaction term). This module adds the integration-only pieces:
//  - HPV-derived circRNA specificity: presence contingency across
//    {HPV+ tumour, HPV- tumour, normal} with the minimum-expression gate.
//  - E6/E7 linear load as a continuous covariate vs circRNA burden / top DE
//    circRNAs / miRNA.
//  - Cross-check HPV_DETECTION linear call vs clinical hpv_status; flag
//    discordant patients.
//
// TODO: real logic lives in bin/hpv_axis.R — this process is a scaffold.

process INTEGRATION_HPV_AXIS {
    label 'process_medium'
    container 'PLACEHOLDER/bioconductor-integration'

    publishDir "${params.outdir}/integration/hpv_axis", mode: 'copy'

    input:
    path mae
    path hpv_circrna_calls, stageAs: 'hpv_circrna/*'
    path samplesheet

    output:
    path 'hpv_axis/*.tsv', emit: results

    script:
    """
    # TODO: not implemented — see bin/hpv_axis.R
    mkdir -p hpv_axis
    hpv_axis.R \\
        --mae ${mae} \\
        --hpv-circrna-dir hpv_circrna \\
        --samplesheet ${samplesheet} \\
        --outdir hpv_axis
    """

    stub:
    """
    mkdir -p hpv_axis
    touch hpv_axis/hpv_circrna_specificity.tsv \\
          hpv_axis/e6e7_load_correlation.tsv \\
          hpv_axis/hpv_status_concordance.tsv
    """
}
