// INTEGRATION_STRUCTURE — unsupervised multi-omic structure (Q3a/Q3b). See
// pipeline_architecture.md §3, analysis_questions_master_list.md (Q3), and
// bin/structure_clustering.R.
//
// Per-modality: ConsensusClusterPlus on each of {circRNA, mRNA, miRNA, CNV}
//   tumour matrices independently -> per-modality partitions.
// Joint: iClusterBayes (iClusterPlus) across available views — Gaussian for
//   expression/CNV, binomial for the binary mutation matrix; each view
//   pre-filtered to top-variance features; run on the patient subset with the
//   required views present (report n used).
// Compare: adjusted Rand index (mclust::adjustedRandIndex) for every partition
//   pair + each vs hpv_status -> ARI matrix. Answers Q3a (which modality's
//   partition tracks the joint solution / iClusterBayes per-view feature-
//   selection probability) and Q3b (does any partition align with HPV status).
// Report subsampling cluster stability. Exploratory at n≈30.
//
// TODO: iClusterBayes per-view feature cap + required-view subset policy is an
// open item — see pipeline_architecture.md §6. Real logic lives in
// bin/structure_clustering.R — this process is a scaffold.

process INTEGRATION_STRUCTURE {
    label 'process_high'
    container 'PLACEHOLDER/bioconductor-integration'   // iClusterPlus, ConsensusClusterPlus, mclust

    publishDir "${params.outdir}/integration/structure", mode: 'copy'

    input:
    path mae

    output:
    path 'structure/*', emit: results

    script:
    """
    # TODO: not implemented — see bin/structure_clustering.R
    mkdir -p structure
    structure_clustering.R \\
        --mae ${mae} \\
        --outdir structure
    """

    stub:
    """
    mkdir -p structure
    touch structure/per_modality_partitions.tsv \\
          structure/iclusterbayes_assignments.tsv \\
          structure/ari_matrix.tsv \\
          structure/cluster_stability.tsv
    """
}
