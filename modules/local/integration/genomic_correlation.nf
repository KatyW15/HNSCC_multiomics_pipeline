// INTEGRATION_GENOMIC — circRNA loci / burden vs somatic genomic alterations.
// See pipeline_architecture.md §3, analysis_questions_master_list.md
// (Supporting / Mechanistic — Genomic drivers of circRNA biogenesis; Q1c), and
// bin/genomic_correlation.R.
//
// (a) GRanges overlap of circRNA loci with consensus CNV amp/del + Manta SV
//     breakpoints; enrichment of DE / tumour-specific circRNAs in amplicons
//     (11q13/CCND1) — Fisher / permutation.
// (b) Dosage: Spearman circRNA abundance vs local gene-level copy number.
// (c) circRNA burden (distinct circRNAs; total BSJ reads) vs TMB (Spearman)
//     and vs driver mutations TP53 / splicing factors (Wilcoxon, effect size + CI).
// (d) HPV-integration proximity vs circRNA output at disrupted loci (case-level).
// Respects coverage_qc_pass in MAE colData for all SV/CNV-dependent tests.
//
// TODO: real logic lives in bin/genomic_correlation.R — this process is a scaffold.

process INTEGRATION_GENOMIC {
    label 'process_medium'
    container 'PLACEHOLDER/bioconductor-integration'

    publishDir "${params.outdir}/integration/genomic_correlation", mode: 'copy'

    input:
    path mae
    path gtf

    output:
    path 'genomic_correlation/*.tsv', emit: results

    script:
    """
    # TODO: not implemented — see bin/genomic_correlation.R
    mkdir -p genomic_correlation
    genomic_correlation.R \\
        --mae ${mae} \\
        --gtf ${gtf} \\
        --outdir genomic_correlation
    """

    stub:
    """
    mkdir -p genomic_correlation
    touch genomic_correlation/locus_overlap.tsv \\
          genomic_correlation/dosage.tsv \\
          genomic_correlation/burden_vs_tmb.tsv \\
          genomic_correlation/hpv_integration_proximity.tsv
    """
}
