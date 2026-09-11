// CIRCRNA_QUANT_MATRIX — build the cohort circRNA count / CPM matrices from the
// per-sample CIRIquant GTFs, restricted to the DE-eligible BSJ set:
// n_tools >= params.circrna_min_tools (default 2) AND detected by CIRIquant.
// See pipeline_architecture.md §3 `CIRCRNASEQ` (decisions 4 & 7, open items
// #20 & #24).
//
// Outputs the `circRNA_bsj` (raw) and `circRNA_cpm` matrices that
// INTEGRATION_ASSEMBLE expects, plus the per-sample circular/linear junction
// ratio table (CIRIquant native — no separate ratio test at this stage,
// decision 20).
//
// Real logic lives in bin/circrna_build_matrix.R — scaffold for now.

process CIRCRNA_QUANT_MATRIX {
    label 'process_medium'
    container 'PLACEHOLDER/bioconductor-integration'

    publishDir "${params.outdir}/circrnaseq/quantification", mode: 'copy'

    input:
    path ciriquant_gtfs, stageAs: 'ciriquant/*'
    path annotated_tsv
    path samplesheet

    output:
    path 'circrna_bsj_counts.tsv',       emit: bsj_counts
    path 'circrna_cpm.tsv',              emit: cpm
    path 'circrna_linear_ratio.tsv',    emit: circ_linear_ratio

    script:
    def min_tools = params.circrna_min_tools ?: 2
    """
    # TODO: not implemented — see bin/circrna_build_matrix.R
    circrna_build_matrix.R \\
        --ciriquant-dir ciriquant \\
        --annotated ${annotated_tsv} \\
        --samplesheet ${samplesheet} \\
        --min-tools ${min_tools} \\
        --out-counts circrna_bsj_counts.tsv \\
        --out-cpm circrna_cpm.tsv \\
        --out-ratio circrna_linear_ratio.tsv
    """

    stub:
    """
    printf 'circ_id\\tsampleA\\tsampleB\\n chr1:1000-2000\\t7\\t3\\n' > circrna_bsj_counts.tsv
    printf 'circ_id\\tsampleA\\tsampleB\\n chr1:1000-2000\\t12.4\\t5.1\\n' > circrna_cpm.tsv
    printf 'circ_id\\tsample\\tjunction_ratio\\n chr1:1000-2000\\tsampleA\\t0.18\\n' > circrna_linear_ratio.tsv
    """
}
