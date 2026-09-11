// STAR_ALIGN_CIRC — the single shared STAR pass for the circRNA arm. Chimeric
// detection is on so CIRCexplorer2 can parse Chimeric.out.junction; gene counts
// feed RNASER_QC; unmapped reads are handed to HPV_DETECTION. See
// pipeline_architecture.md §3 `CIRCRNASEQ` and open item #23 (chimeric params —
// keep in sync with the Stage 1a nf-core/rnaseq --extra_star_align_args so the
// cross-library co-validation compares like with like).

process STAR_ALIGN_CIRC {
    tag "${meta.id}"
    label 'process_high'
    container 'quay.io/biocontainers/star:2.7.11b--h43eeafb_1'   // TODO: pin via shared container policy

    publishDir "${params.outdir}/circrnaseq/star/${meta.id}", mode: 'copy'

    input:
    tuple val(meta), path(reads)
    path index
    path gtf

    output:
    tuple val(meta), path('*.Chimeric.out.junction'),        emit: chimeric
    tuple val(meta), path('*.Aligned.sortedByCoord.out.bam'), emit: bam
    tuple val(meta), path('*.ReadsPerGene.out.tab'),          emit: gene_counts
    tuple val(meta), path('*.Log.final.out'),                 emit: log_final
    tuple val(meta), path('unmapped/*'), optional: true,      emit: unmapped

    script:
    def chimeric_args = params.star_chimeric_args ?: '--chimSegmentMin 12 --chimJunctionOverhangMin 12 --chimScoreMin 1 --chimScoreDropMax 20 --chimScoreSeparation 10 --chimOutType Junctions'
    """
    STAR \\
        --runMode alignReads \\
        --genomeDir ${index} \\
        --sjdbGTFfile ${gtf} \\
        --readFilesIn ${reads} \\
        --readFilesCommand zcat \\
        --runThreadN ${task.cpus} \\
        --outSAMtype BAM SortedByCoordinate \\
        --quantMode GeneCounts \\
        --outReadsUnmapped Fastx \\
        --twopassMode Basic \\
        ${chimeric_args} \\
        --outFileNamePrefix ${meta.id}.

    mkdir unmapped
    for m in ${meta.id}.Unmapped.out.mate1 ${meta.id}.Unmapped.out.mate2; do
        [ -f "\$m" ] && gzip -c "\$m" > unmapped/\$(basename "\$m").fastq.gz || true
    done
    """

    stub:
    """
    mkdir unmapped
    touch ${meta.id}.Chimeric.out.junction ${meta.id}.Aligned.sortedByCoord.out.bam \\
          ${meta.id}.ReadsPerGene.out.tab ${meta.id}.Log.final.out \\
          unmapped/${meta.id}.Unmapped.out.mate1.fastq.gz
    """
}
