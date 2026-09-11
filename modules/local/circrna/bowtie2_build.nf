// BOWTIE2_BUILD — Bowtie2 index for find_circ's anchor alignment. Skipped when
// params.bowtie2_index is set. See pipeline_architecture.md §3 `CIRCRNASEQ`.

process BOWTIE2_BUILD {
    label 'process_high'
    container 'quay.io/biocontainers/bowtie2:2.5.4--he96a11b_0'   // TODO: pin via shared container policy

    publishDir "${params.outdir}/circrnaseq/reference", mode: 'copy'

    input:
    path fasta

    output:
    path 'bowtie2_index', emit: index

    script:
    """
    mkdir bowtie2_index
    bowtie2-build --threads ${task.cpus} ${fasta} bowtie2_index/${fasta.baseName}
    """

    stub:
    """
    mkdir bowtie2_index
    touch bowtie2_index/${fasta.baseName}.1.bt2
    """
}
