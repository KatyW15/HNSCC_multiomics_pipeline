// RNASER_QC — RNase R treatment-efficiency QC (decision 14). A failed RNase R
// prep silently inflates linear-RNA background and confounds every
// circular/linear comparison downstream, so surface a per-library efficiency
// metric as a custom MultiQC section. See pipeline_architecture.md §3
// `CIRCRNASEQ`.
//
// Metric: from the shared STAR ReadsPerGene / gene-body coverage, the fraction
// of signal in known linear-only features (e.g. intronic / single-exon
// housekeeping transcripts that cannot circularise) vs total — low = good
// digestion. Exact definition is a scaffold decision in bin/rnaser_efficiency.py.

process RNASER_QC {
    label 'process_low'
    container 'PLACEHOLDER/bioconductor-integration'   // or a small python image — TBD with container policy

    publishDir "${params.outdir}/circrnaseq/qc", mode: 'copy'

    input:
    path gene_count_tabs, stageAs: 'star_counts/*'
    path gtf
    path samplesheet

    output:
    path 'rnase_r_efficiency.tsv',        emit: table
    path 'rnase_r_efficiency_mqc.tsv',    emit: mqc

    script:
    """
    # TODO: not implemented — see bin/rnaser_efficiency.py
    rnaser_efficiency.py \\
        --star-counts-dir star_counts \\
        --gtf ${gtf} \\
        --samplesheet ${samplesheet} \\
        --out rnase_r_efficiency.tsv \\
        --out-mqc rnase_r_efficiency_mqc.tsv
    """

    stub:
    """
    printf 'sample\\tlinear_fraction\\trnase_r_pass\\n sampleA\\t0.08\\ttrue\\n' > rnase_r_efficiency.tsv
    cp rnase_r_efficiency.tsv rnase_r_efficiency_mqc.tsv
    """
}
