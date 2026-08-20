// CIRCRNASEQ — RNase R-treated circRNA-seq, host genome. See
// pipeline_architecture.md §3.
//
// TODO:
// - FastQC -> trimming -> per-tool alignment (CIRI2/BWA, CIRCexplorer3/STAR,
//   find_circ/Bowtie2)
// - ensemble BSJ calling across the three tools; consensus/filtering
//   (min BSJ read support, canonical splice signal, tool-agreement tier)
// - annotate against circBase/circAtlas -> novel/known flag
// - quantification + DESeq2 DE (tumor/normal, HPV+/- interaction term)
// - circular/linear ratio step against RNASEQ_ADAPTER host-gene counts
// - cross-library co-validation against RNASEQ_ADAPTER chimeric junctions

workflow CIRCRNASEQ {
    take:
    samples
    chimeric_junctions   // from RNASEQ_ADAPTER, for cross-library co-validation

    main:
    // TODO

    emit:
    calls    = Channel.empty()
    de       = Channel.empty()
    unmapped = Channel.empty()   // for HPV_DETECTION
}
