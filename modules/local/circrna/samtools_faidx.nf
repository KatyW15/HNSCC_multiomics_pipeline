// SAMTOOLS_FAIDX — .fai index for the hg38 FASTA. Used by CIRI2/CIRIquant and
// by the CIRCRNA_CONSENSUS GT/AG splice-motif check. See
// pipeline_architecture.md §3 `CIRCRNASEQ`.

process SAMTOOLS_FAIDX {
    label 'process_low'
    container 'quay.io/biocontainers/samtools:1.21--h50ea8bc_0'   // TODO: pin via shared container policy (pipeline_architecture.md §5)

    publishDir "${params.outdir}/circrnaseq/reference", mode: 'copy'

    input:
    path fasta

    output:
    path "${fasta}.fai", emit: fai

    script:
    """
    samtools faidx ${fasta}
    """

    stub:
    """
    touch ${fasta}.fai
    """
}
