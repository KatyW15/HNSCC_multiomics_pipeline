// INTEGRATION_CANDIDATE_REGISTRY — one master feature table cross-flagging
// every circRNA across all integration modules, with a transparent rule-based
// priority ordering. This is the "logical way to parse the data" artefact —
// the table you scan first. See pipeline_architecture.md §3 and
// bin/candidate_registry.R.
//
// Per circRNA: DE stats (Q1/Q2), recurrence tier, novel/known flag,
// expression-gate pass, ceRNA support + partners, genomic context (in amplicon
// / near SV / CN-correlated), HPV-axis flags, biomarker selection frequency,
// iClusterBayes per-view feature-selection probability.
//
// TODO: exact composite priority rule is an open item — see
// pipeline_architecture.md §6. Real logic lives in bin/candidate_registry.R.

process INTEGRATION_CANDIDATE_REGISTRY {
    label 'process_low'
    container 'PLACEHOLDER/bioconductor-integration'

    publishDir "${params.outdir}/integration", mode: 'copy'

    input:
    path module_outputs, stageAs: 'module_outputs/*'

    output:
    path 'candidate_registry.tsv', emit: registry

    script:
    """
    # TODO: not implemented — see bin/candidate_registry.R
    candidate_registry.R \\
        --module-outputs-dir module_outputs \\
        --out candidate_registry.tsv
    """

    stub:
    """
    touch candidate_registry.tsv
    """
}
