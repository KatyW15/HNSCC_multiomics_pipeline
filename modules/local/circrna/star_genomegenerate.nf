// STAR_GENOMEGENERATE — STAR index for the shared chimeric-aware alignment
// (feeds CIRCexplorer2). Skipped when params.star_index is set. See
// pipeline_architecture.md §3 `CIRCRNASEQ` and open item #23 (chimeric params).

process STAR_GENOMEGENERATE {
    label 'process_high'
    container 'quay.io/biocontainers/star:2.7.11b--h43eeafb_1'   // TODO: pin via shared container policy

    publishDir "${params.outdir}/circrnaseq/reference", mode: 'copy'

    input:
    path fasta
    path gtf

    output:
    path 'star_index', emit: index

    script:
    def sjdb_overhang = params.star_sjdb_overhang ?: 149
    """
    mkdir star_index
    STAR \\
        --runMode genomeGenerate \\
        --genomeDir star_index \\
        --genomeFastaFiles ${fasta} \\
        --sjdbGTFfile ${gtf} \\
        --sjdbOverhang ${sjdb_overhang} \\
        --runThreadN ${task.cpus}
    """

    stub:
    """
    mkdir star_index
    touch star_index/SAindex
    """
}
