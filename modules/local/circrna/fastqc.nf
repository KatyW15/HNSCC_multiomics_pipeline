// FASTQC — pre-trim read QC for the circRNA-seq libraries. Feeds MultiQC via
// the REPORTING subworkflow. See pipeline_architecture.md §3 `CIRCRNASEQ`.
//
// Local module for now; swap for the canonical nf-core/fastqc module once the
// repo adopts `nf-core modules` tooling (pipeline_architecture.md §5).

process FASTQC {
    tag "${meta.id}"
    label 'process_medium'
    container 'quay.io/biocontainers/fastqc:0.12.1--hdfd78af_0'

    publishDir "${params.outdir}/circrnaseq/fastqc", mode: 'copy'

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path('*.html'), emit: html
    tuple val(meta), path('*.zip'),  emit: zip

    script:
    """
    fastqc --threads ${task.cpus} ${reads}
    """

    stub:
    """
    touch ${meta.id}_R1_fastqc.html ${meta.id}_R1_fastqc.zip
    """
}
