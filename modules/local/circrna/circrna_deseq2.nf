// CIRCRNA_DESEQ2 — paired differential circRNA expression. Design MIRRORS the
// host-gene and miRNA models exactly so INTEGRATION_RECURRENCE can stack the
// tables: ~ patient + hpv_status + tissue + hpv_status:tissue. Patients
// without a matched normal are dropped from this model (decision 18).
// Low-count prefilter: >= params.circrna_min_expr_reads in
// >= params.circrna_min_expr_samples_frac of samples in at least one tissue
// group (decision 19). Size-factor strategy left open — poscounts placeholder
// (open item #20).
// See pipeline_architecture.md §3 `CIRCRNASEQ` and open item #17 (counterpart).
//
// Real logic lives in bin/circrna_deseq2.R — scaffold for now.

process CIRCRNA_DESEQ2 {
    label 'process_medium'
    container 'PLACEHOLDER/bioconductor-integration'   // DESeq2

    publishDir "${params.outdir}/circrnaseq/differential_expression", mode: 'copy'

    input:
    path bsj_counts
    path annotated_tsv
    path samplesheet

    output:
    path 'circrna_de.*.tsv',           emit: tables
    path 'circrna_de.dds.rds',         emit: dds
    path 'circrna_de.sizefactors.tsv', emit: sizefactors

    script:
    def sf_method   = params.circrna_deseq2_sizefactors ?: 'poscounts'
    def min_reads   = params.circrna_min_expr_reads ?: 2
    def min_frac    = params.circrna_min_expr_samples_frac ?: 0.25
    """
    # TODO: not implemented — see bin/circrna_deseq2.R
    circrna_deseq2.R \\
        --counts ${bsj_counts} \\
        --annotated ${annotated_tsv} \\
        --samplesheet ${samplesheet} \\
        --design '~ patient + hpv_status + tissue + hpv_status:tissue' \\
        --drop-unpaired \\
        --sizefactor-method ${sf_method} \\
        --min-reads ${min_reads} \\
        --min-samples-frac ${min_frac} \\
        --contrasts tumor_vs_normal,hpv_interaction \\
        --outprefix circrna_de
    """

    stub:
    """
    printf 'circ_id\\tlog2FoldChange\\tpvalue\\tpadj\\n chr1:1000-2000\\t1.8\\t0.001\\t0.02\\n' > circrna_de.tumor_vs_normal.tsv
    printf 'circ_id\\tlog2FoldChange\\tpvalue\\tpadj\\n chr1:1000-2000\\t0.4\\t0.3\\t0.7\\n' > circrna_de.hpv_interaction.tsv
    touch circrna_de.dds.rds
    printf 'sample\\tsizefactor\\n sampleA\\t1.02\\n' > circrna_de.sizefactors.tsv
    """
}
