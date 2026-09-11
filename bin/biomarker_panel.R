#!/usr/bin/env Rscript

# biomarker_panel.R — candidate circRNA biomarker panel.
#
# Purpose : Can a minimal, feature-selected, cross-validated circRNA panel
#           classify tumour vs normal, or HPV+ vs HPV-?
# Answers : analysis_questions_master_list.md -> Supporting / Mechanistic
#           ("Biomarker panel / classifier").
# Inputs  : mae.rds (circRNA assays + hpv_status, tissue); circRNA DE tables
#           (to define the high-confidence candidate set).
# Outputs : tumour_vs_normal_panel.tsv, hpv_pos_vs_neg_panel.tsv,
#           cv_performance.tsv
#
# Method:
#   - Feature space: high-confidence circRNAs (consensus tier + passes the
#     minimum-expression gate), optionally + top miRNA.
#   - Nested cross-validation: outer LOOCV or repeated stratified 5-fold for
#     honest performance; inner folds for feature selection + hyperparameters.
#   - Model: glmnet elastic net and/or random forest with stability selection.
#   - Report: AUC with CI, per-fold selected-feature frequency, final consensus
#     panel.
#   - n≈30: strictly hypothesis-generating. Label outputs as such. Do NOT
#     present as a validated classifier.

suppressPackageStartupMessages({
  library(optparse)
  # library(MultiAssayExperiment)
  # library(glmnet)
  # library(randomForest)
  # library(pROC)
})

parse_args_or_die <- function() {
  option_list <- list(
    make_option("--mae", type = "character"),
    make_option("--circrna-de-dir", type = "character", dest = "circrna_de_dir"),
    make_option("--outdir", type = "character"),
    make_option("--outer-cv", type = "character", default = "loocv", dest = "outer_cv"),
    make_option("--repeats", type = "integer", default = 50L),
    make_option("--add-mirna", action = "store_true", default = FALSE, dest = "add_mirna")
  )
  parse_args(OptionParser(option_list = option_list))
}

candidate_features <- function(mae, de_dir, add_mirna) stop("not implemented: high-confidence circRNA (+ optional miRNA) feature matrix")
nested_cv_classifier <- function(x, y, outer_cv, repeats) stop("not implemented: nested CV elastic net / RF + stability selection, AUC + CI")

main <- function() {
  opt <- parse_args_or_die()
  stop("biomarker_panel.R is a scaffold — not implemented. See header for the intended contract.")
}

if (identical(environment(), globalenv())) main()
