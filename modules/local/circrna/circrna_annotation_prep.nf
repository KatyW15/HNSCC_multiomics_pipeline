// CIRCRNA_ANNOTATION_PREP — normalise the pinned circAtlas hg38 release into
// (a) a known-circRNA BED and (b) a circRNA annotation GTF, both on the
// chr-prefixed contig convention shared with the Sarek/GENCODE bundle
// (pipeline_architecture.md open item #11). See open item #16 (pin the
// release) and §3 `CIRCRNASEQ`.
//
// Real logic lives in bin/circrna_annotation_prep.R — scaffold for now.

process CIRCRNA_ANNOTATION_PREP {
    label 'process_low'
    container 'PLACEHOLDER/bioconductor-integration'   // GenomicRanges, rtracklayer, bedtools

    publishDir "${params.outdir}/circrnaseq/reference", mode: 'copy'

    input:
    path circatlas_raw
    path gtf

    output:
    path 'known_circ.hg38.bed',      emit: known_circ_bed
    path 'circrna_annotation.gtf',   emit: circ_annotation

    script:
    """
    # TODO: not implemented — see bin/circrna_annotation_prep.R
    circrna_annotation_prep.R \\
        --circatlas ${circatlas_raw} \\
        --gtf ${gtf} \\
        --contig-style chr \\
        --out-bed known_circ.hg38.bed \\
        --out-gtf circrna_annotation.gtf
    """

    stub:
    """
    touch known_circ.hg38.bed circrna_annotation.gtf
    """
}
