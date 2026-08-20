// REPORTING — MultiQC + cohort-level report. See pipeline_architecture.md §3.
//
// TODO: MultiQC for standard per-sample QC; a custom cohort-level report
// (R Markdown/Quarto) assembling the INTEGRATION outputs into one document
// per pipeline run, published under results/reports/cohort_report_<date>.html.

workflow REPORTING {
    take:
    integration_out

    main:
    // TODO

    emit:
    report = Channel.empty()
}
