// SMRNASEQ — miRNA. See pipeline_architecture.md §3.
//
// TODO: adapter trimming (short-read specific) -> Bowtie alignment ->
// miRDeep2 (known + novel miRNA) -> DESeq2 DE. Feeds INTEGRATION for the
// ceRNA network step. Not every patient has this modality — INPUT_CHECK
// already only routes samples that exist here.
//
// NOTE: pin the miRBase release used here — INTEGRATION_ASSEMBLE
// (bin/assemble_mae.R) needs a fixed miRNA naming/version to harmonise the
// miRNA_counts assay against target-prediction databases.

workflow SMRNASEQ {
    take:
    samples

    main:
    // TODO

    emit:
    de = Channel.empty()
}
