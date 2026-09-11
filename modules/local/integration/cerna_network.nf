// INTEGRATION_CERNA — circRNA–miRNA(–mRNA) ceRNA / sponge network. See
// pipeline_architecture.md §3, analysis_questions_master_list.md
// (Supporting / Mechanistic — circRNA–miRNA sponge support), and
// bin/cerna_network.R.
//
// Intersect predicted MREs (MIRNA_TARGET_PREDICT) with negative Spearman
// circRNA–miRNA correlation across tumours (permutation FDR); extend to
// circRNA↓–miRNA↑–mRNA(target)↓ triads via TargetScan / miRTarBase. Emits an
// edge list + node table. Exploratory at n≈30 — wide correlation CIs.
//
// TODO: real logic lives in bin/cerna_network.R — this process is a scaffold.

process INTEGRATION_CERNA {
    label 'process_medium'
    container 'PLACEHOLDER/bioconductor-integration'

    publishDir "${params.outdir}/integration/cerna_network", mode: 'copy'

    input:
    path mae
    path circrna_mirna_pairs

    output:
    path 'cerna_edges.tsv', emit: network
    path 'cerna_nodes.tsv', emit: nodes

    script:
    """
    # TODO: not implemented — see bin/cerna_network.R
    cerna_network.R \\
        --mae ${mae} \\
        --pairs ${circrna_mirna_pairs} \\
        --out-edges cerna_edges.tsv \\
        --out-nodes cerna_nodes.tsv
    """

    stub:
    """
    touch cerna_edges.tsv cerna_nodes.tsv
    """
}
