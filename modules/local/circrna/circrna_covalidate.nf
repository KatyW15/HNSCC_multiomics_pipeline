// CIRCRNA_COVALIDATE — cross-library co-validation (Q1d). Intersect the
// annotated consensus BSJ set with the STAR chimeric junctions exported by the
// Stage 1a nf-core/rnaseq run (via RNASEQ_ADAPTER), adding a
// `validated_in_totalRNA` boolean (+ supporting chimeric read count) to the
// candidate table. See pipeline_architecture.md §3 `CIRCRNASEQ` and open
// items #10 & #23 (the chimeric params must match on both sides for this to
// mean anything).
//
// Tolerates an empty chimeric-junction input (RNASEQ_ADAPTER not run / not
// wired yet) — the column is then written as NA.
//
// Real logic lives in bin/circrna_covalidate.R — scaffold for now.

process CIRCRNA_COVALIDATE {
    label 'process_low'
    container 'PLACEHOLDER/bioconductor-integration'

    publishDir "${params.outdir}/circrnaseq/annotation", mode: 'copy'

    input:
    path annotated_tsv
    path chimeric_junctions, stageAs: 'chimeric/*'

    output:
    path 'circrna_candidates.tsv', emit: table

    script:
    """
    mkdir -p chimeric   # may be empty — RNASEQ_ADAPTER not wired yet (tolerated)

    # TODO: not implemented — see bin/circrna_covalidate.R
    circrna_covalidate.R \\
        --annotated ${annotated_tsv} \\
        --chimeric-dir chimeric \\
        --match-slop ${params.circrna_bsj_merge_slop ?: 5} \\
        --out circrna_candidates.tsv
    """

    stub:
    """
    printf 'circ_id\\thost_gene\\tknown\\tmax_n_tools\\tvalidated_in_totalRNA\\tchimeric_reads\\n' > circrna_candidates.tsv
    printf 'chr1:1000-2000\\tGENEA\\tknown\\t3\\ttrue\\t6\\n' >> circrna_candidates.tsv
    """
}
