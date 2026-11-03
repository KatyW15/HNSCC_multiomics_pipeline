// RNASEQ_ADAPTER — total RNA-seq arm, part (b): the Stage 2 adapter. Part (a)
// (the pinned nf-core/rnaseq v3.26.0 invocation) runs externally and is not
// vendored here — see stage1/ for its launch script and samplesheet generation.
// This subworkflow does NOT run its own alignment — it ingests the external
// Stage 1a output directory. See pipeline_architecture.md §3.
//
// TODO:
// - after Stage 1a completes, ingest salmon gene counts -> host-gene DESeq2
// - ingest STAR chimeric junctions (via --extra_star_align_args on Stage 1a)
//   -> hand off to CIRCRNASEQ for cross-library BSJ co-validation
//   (verify these are actually published by nf-core/rnaseq first — open
//   item #10 in pipeline_architecture.md)

workflow RNASEQ_ADAPTER {
    take:
    samples
    rnaseq_results_dir

    main:
    // TODO

    emit:
    gene_counts        = Channel.empty()
    chimeric_junctions = Channel.empty()
}
