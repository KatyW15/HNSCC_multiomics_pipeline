#!/usr/bin/env Rscript

# recurrence_score.R — recurrence / "commonality" scoring.
#
# Purpose : For every cohort-level DE feature (circRNA / miRNA / host-gene),
#           report in how many individual patients that feature is itself
#           altered in the same direction — a confidence/commonality weighting
#           layered on top of DESeq2 significance.
# Answers : analysis_questions_master_list.md -> Cross-Cutting Methodological
#           Notes ("Patient recurrence / commonality score"). Feeds Q1 / Q2.
# Inputs  : mae.rds; a directory of DE result tables (one per modality/contrast).
# Outputs : each DE table re-written with added columns:
#             n_patients_tested, n_patients_concordant, frac_concordant,
#             commonality_tier
#
# Method (no model — pure bookkeeping):
#   - For each patient with BOTH tumour and its own normal for the modality,
#     compute the per-patient paired log2 fold-change per feature.
#   - concordant = sign(per-patient log2FC) matches sign(cohort log2FC)
#     (optionally also |per-patient log2FC| >= a small threshold).
#   - frac_concordant = n_patients_concordant / n_patients_tested.
#   - commonality_tier = cut(frac_concordant) into e.g. high/moderate/low.
#   - n_patients_tested varies by modality coverage — always report it.

suppressPackageStartupMessages({
  library(optparse)
  # library(MultiAssayExperiment)
})

parse_args_or_die <- function() {
  option_list <- list(
    make_option("--mae", type = "character"),
    make_option("--de-dir", type = "character", dest = "de_dir"),
    make_option("--outdir", type = "character"),
    make_option("--min-abs-log2fc", type = "double", default = 0.0, dest = "min_abs_log2fc")
  )
  parse_args(OptionParser(option_list = option_list))
}

per_patient_paired_lfc <- function(mae, modality) stop("not implemented: paired tumour-vs-own-normal log2FC matrix (feature x patient)")
score_table <- function(de_table, lfc_matrix, min_abs_log2fc) stop("not implemented: append n_patients_concordant / frac_concordant / commonality_tier")

main <- function() {
  opt <- parse_args_or_die()
  stop("recurrence_score.R is a scaffold — not implemented. See header for the intended contract.")
}

if (identical(environment(), globalenv())) main()
