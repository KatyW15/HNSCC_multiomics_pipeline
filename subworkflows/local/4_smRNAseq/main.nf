// SMRNASEQ_ADAPTER — wraps Stage 1c (nf-core/smrnaseq, version pin TBD —
// open item #19). The pinned nf-core/smrnaseq invocation runs externally (see
// stage1/ for its launch script and samplesheet generation) and does the
// trimming, miRBase alignment, miRDeep2 novel-miRNA discovery, and mirtop
// isomiR quantification. This subworkflow does NOT run its own alignment — it
// ingests the external Stage 1c output directory. See pipeline_architecture.md
// §3.
//
// TODO:
// - after Stage 1c completes, ingest its miRNA count matrix (confirm which
//   file the pinned version publishes — mirtop TSV vs per-sample tables)
// - miRNA DESeq2 DE (paired tumor/normal, HPV+/- with interaction term),
//   matching the host-gene and circRNA DE models. nf-core/smrnaseq's own
//   edgeR stats are exploratory only and not used here.
// - feeds INTEGRATION (miRNA_counts assay) for the ceRNA network and
//   structure clustering. Not every patient has this modality — INPUT_CHECK
//   already only routes samples that exist here.
//
// NOTE: pin the miRBase release in stage1/params/smrnaseq.yaml —
// INTEGRATION_ASSEMBLE (bin/assemble_mae.R) needs a fixed miRNA naming/version
// to harmonise the miRNA_counts assay against target-prediction databases
// (open item #12).

workflow SMRNASEQ_ADAPTER {
    take:
    samples
    smrnaseq_results_dir

    main:
    // TODO

    emit:
    mirna_counts = Channel.empty()
    de           = Channel.empty()
}
