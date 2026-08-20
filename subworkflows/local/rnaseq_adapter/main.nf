// RNASEQ_ADAPTER — wraps Stage 1a (nf-core/rnaseq v3.26.0). See
// pipeline_architecture.md §3. Does NOT run its own alignment — ingests the
// external Stage 1a output directory.
//
// TODO:
// - auto-generate the Stage 1a samplesheet from the master samplesheet
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
