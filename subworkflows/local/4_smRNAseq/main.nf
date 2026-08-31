// SMRNASEQ — miRNA. See pipeline_architecture.md §3.
//
// TODO: adapter trimming (short-read specific) -> Bowtie alignment ->
// miRDeep2 (known + novel miRNA) -> DESeq2 DE. Feeds INTEGRATION for the
// ceRNA network step. Not every patient has this modality — INPUT_CHECK
// already only routes samples that exist here.

workflow SMRNASEQ {
    take:
    samples

    main:
    // TODO

    emit:
    de = Channel.empty()
}
