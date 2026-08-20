// INPUT_CHECK — see pipeline_architecture.md §3
// TODO: validate samplesheet against nextflow_schema.json (controlled vocab
// on tissue/modality/hpv_status, path existence for non-blank fastqs);
// branch into per-modality channels; emit a patient-completeness report.

workflow INPUT_CHECK {
    take:
    samplesheet

    main:
    // TODO

    emit:
    rnaseq     = Channel.empty()
    circrnaseq = Channel.empty()
    smrnaseq   = Channel.empty()
    wgs        = Channel.empty()
}
