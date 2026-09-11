// BWA_INDEX — BWA index for CIRIquant's internal CIRI2 alignment. Skipped when
// params.bwa_index is set. See pipeline_architecture.md §3 `CIRCRNASEQ`.

process BWA_INDEX {
    label 'process_high'
    container 'quay.io/biocontainers/bwa:0.7.18--he4a0461_1'   // TODO: pin via shared container policy

    publishDir "${params.outdir}/circrnaseq/reference", mode: 'copy'

    input:
    path fasta

    output:
    path 'bwa_index', emit: index

    script:
    """
    mkdir bwa_index
    bwa index -p bwa_index/${fasta.baseName} ${fasta}
    """

    stub:
    """
    mkdir bwa_index
    touch bwa_index/${fasta.baseName}.bwt
    """
}
