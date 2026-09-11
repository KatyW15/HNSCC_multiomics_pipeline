// CIRCEXPLORER2 — STAR-arm BSJ detection. Parses the shared
// Chimeric.out.junction, then annotates against the circRNA annotation GTF.
// Emits a normalised BSJ BED: chr, start, end, name, bsj_reads, strand.
// See pipeline_architecture.md §3 `CIRCRNASEQ` (decision 1: CIRCexplorer2,
// not 3 — CLEAR's ratio role is covered by CIRIquant).

process CIRCEXPLORER2 {
    tag "${meta.id}"
    label 'process_medium'
    container 'quay.io/biocontainers/circexplorer2:2.3.8--pyh864c0ab_1'   // TODO: pin via shared container policy

    publishDir "${params.outdir}/circrnaseq/calls/circexplorer2", mode: 'copy'

    input:
    tuple val(meta), path(chimeric_junction)
    path fasta
    path annotation_gtf

    output:
    tuple val(meta), path("${meta.id}.circexplorer2.bsj.bed"), emit: bsj
    tuple val(meta), path("${meta.id}.circexplorer2.txt"),     emit: raw

    script:
    // NOTE: CIRCexplorer2 `annotate` needs a genePred/refFlat-style annotation,
    // not a raw GTF. `gtfToGenePred` (UCSC) is bundled in the circexplorer2
    // biocontainer's deps; if a future container drops it, generate the
    // genePred once in CIRCRNA_ANNOTATION_PREP and pass it in instead.
    """
    CIRCexplorer2 parse -t STAR ${chimeric_junction} -b ${meta.id}.back_spliced_junction.bed

    gtfToGenePred -genePredExt -geneNameAsName2 ${annotation_gtf} circ_ref.genePred
    awk 'BEGIN{OFS="\\t"} {print \$12, \$1, \$2, \$3, \$4, \$5, \$6, \$7, \$8, \$9, \$10}' \\
        circ_ref.genePred > circ_ref.txt

    CIRCexplorer2 annotate \\
        -r circ_ref.txt \\
        -g ${fasta} \\
        -b ${meta.id}.back_spliced_junction.bed \\
        -o ${meta.id}.circexplorer2.txt

    # normalise to the common BSJ BED shape (readNumber is column 13 of the
    # CIRCexplorer2 circularRNA_known.txt format)
    awk 'BEGIN{OFS="\\t"} !/^#/ && NF>=13 {print \$1, \$2, \$3, \$1":"\$2"-"\$3, \$13, \$6}' \\
        ${meta.id}.circexplorer2.txt > ${meta.id}.circexplorer2.bsj.bed
    """

    stub:
    """
    touch ${meta.id}.circexplorer2.txt
    printf 'chr1\\t1000\\t2000\\tchr1:1000-2000\\t5\\t+\\n' > ${meta.id}.circexplorer2.bsj.bed
    """
}
