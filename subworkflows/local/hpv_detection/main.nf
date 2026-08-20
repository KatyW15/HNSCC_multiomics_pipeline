// HPV_DETECTION — HPV linear transcripts + HPV circRNAs. See
// pipeline_architecture.md §3. Highest-uncertainty module in the pipeline.
//
// TODO:
// - pull unmapped/soft-clipped reads from RNASEQ_ADAPTER, CIRCRNASEQ, and
//   WGS_ADAPTER (Sarek BAMs)
// - realign to assets/hpv_reference/hpv_panel.fa (HPV16, HPV18, other
//   high-risk genotypes)
// - linear HPV transcript quantification (E6/E7 etc.) -> cross-check
//   against clinical hpv_status
// - HPV circRNA detection: vircircRNA + CIRI2 ensemble against a
//   padded/duplicated HPV reference (DOI: 10.1099/mgen.0.000848)

workflow HPV_DETECTION {
    take:
    rnaseq_unmapped
    circrnaseq_unmapped
    wgs_unmapped

    main:
    // TODO

    emit:
    linear_quant     = Channel.empty()
    circrna_calls    = Channel.empty()
    integration_sites = Channel.empty()
}
