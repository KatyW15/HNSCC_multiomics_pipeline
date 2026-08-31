// WGS_ADAPTER — wraps Stage 1b (nf-core/sarek v3.9.0, --tools
// mutect2,ascat,cnvkit,controlfreec,manta,vep). See pipeline_architecture.md
// §3. Does NOT run its own alignment/calling — ingests the external Stage 1b
// output directory.
//
// TODO:
// - auto-generate the Stage 1b samplesheet from the master samplesheet
// - ingest somatic variants, all three CNV call sets (build consensus/
//   concordance calls), Manta SVs, mosdepth coverage
// - coverage QC gate: flag samples below the depth threshold (TBD once real
//   depth distribution is known) as unreliable for SV/CNV-dependent
//   downstream questions, without dropping their somatic calls
// - pull unmapped/soft-clipped reads -> hand off to HPV_DETECTION
// - verify hg38 contig-naming consistency against the GENCODE reference
//   before any coordinate joins (open item #11 in pipeline_architecture.md)

workflow WGS_ADAPTER {
    take:
    samples
    sarek_results_dir

    main:
    // TODO

    emit:
    somatic_variants = Channel.empty()
    cnv_consensus    = Channel.empty()
    sv_calls         = Channel.empty()
    coverage_qc      = Channel.empty()
    unmapped         = Channel.empty()   // for HPV_DETECTION
}
