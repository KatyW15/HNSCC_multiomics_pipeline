// CIRCRNA_ANNOTATE — cohort-level annotation of the per-sample consensus BSJ
// sets. See pipeline_architecture.md §3 `CIRCRNASEQ` (decisions 15-17).
//
//   - pool per-sample consensus tables into one cohort BSJ set (union),
//     carrying per-sample n_tools / bsj_reads
//   - host gene + exon structure + circRNA type (exonic/intronic/intergenic)
//     from the GENCODE v50 annotation GTF (same file as RNASEQ_ADAPTER)
//   - known/novel flag against the pinned circAtlas hg38 BED (Q1e)
//
// Real logic lives in bin/circrna_annotate.R — scaffold for now.

process CIRCRNA_ANNOTATE {
    label 'process_medium'
    container 'PLACEHOLDER/bioconductor-integration'   // GenomicFeatures, GenomicRanges, rtracklayer

    publishDir "${params.outdir}/circrnaseq/annotation", mode: 'copy'

    input:
    path consensus_tsvs, stageAs: 'consensus/*'
    path annotation_gtf
    path known_circ_bed

    output:
    path 'circrna_annotated.tsv',      emit: annotated
    path 'circrna_cohort_bsj.bed',     emit: cohort_bed

    script:
    """
    # TODO: not implemented — see bin/circrna_annotate.R
    circrna_annotate.R \\
        --consensus-dir consensus \\
        --gtf ${annotation_gtf} \\
        --known-circ ${known_circ_bed} \\
        --out-table circrna_annotated.tsv \\
        --out-bed circrna_cohort_bsj.bed
    """

    stub:
    """
    printf 'circ_id\\tchrom\\tstart\\tend\\tstrand\\thost_gene\\tcirc_type\\tknown\\tn_samples\\tmax_n_tools\\n' > circrna_annotated.tsv
    printf 'chr1:1000-2000\\tchr1\\t1000\\t2000\\t+\\tGENEA\\texonic\\tknown\\t4\\t3\\n' >> circrna_annotated.tsv
    printf 'chr1\\t1000\\t2000\\tchr1:1000-2000\\t.\\t+\\n' > circrna_cohort_bsj.bed
    """
}
