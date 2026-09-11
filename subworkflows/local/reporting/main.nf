// REPORTING — MultiQC + cohort-level report. See pipeline_architecture.md §3.
//
// TODO: MultiQC for standard per-sample QC; a custom cohort-level report
// (Quarto — assets/integration/report_template.qmd) with ONE SECTION PER
// master-list question (Q1a–e, Q2a–b, Q3a–b, each mechanistic bullet), each
// pulling from the matching INTEGRATION module output, and the candidate
// registry as the front section. Published under
// results/reports/cohort_report_<date>.html.

workflow REPORTING {
    take:
    integration_out

    main:
    // TODO

    emit:
    report = Channel.empty()
}
