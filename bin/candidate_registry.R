#!/usr/bin/env Rscript

# candidate_registry.R — cross-module candidate circRNA registry.
#
# Purpose : Collapse every integration module's output into ONE master table,
#           one row per circRNA, so a reader can see at a glance which
#           candidates are supported from multiple independent angles. This is
#           the "logical way to parse the data" artefact.
# Answers : none directly — it is the navigation layer over Q1 / Q2 / Q3 and the
#           mechanistic questions.
# Inputs  : a directory of every upstream integration module output
#           (recurrence tables, cerna edges/nodes, genomic_correlation/*,
#           hpv_axis/*, structure/*, biomarker/*).
# Outputs : candidate_registry.tsv
#
# Columns (per circRNA):
#   circrna_id, host_gene, locus, novel_known,
#   q1_log2fc, q1_padj, q2_log2fc, q2_padj,
#   recurrence_frac, recurrence_tier, expression_gate_pass,
#   cerna_support (bool), cerna_partners,
#   in_amplicon (bool), near_sv (bool), cn_correlated (bool),
#   hpv_specific (bool), e6e7_load_assoc,
#   biomarker_selection_freq, iclusterbayes_featsel_prob,
#   priority
#
# priority: a TRANSPARENT rule-based ordering (documented, reproducible — NOT a
# black-box score). Exact rule is an OPEN ITEM — see pipeline_architecture.md
# section 6. e.g. rank by (recurrence_tier, then n independent supporting lines
# of evidence, then |q1_log2fc|).

suppressPackageStartupMessages({
  library(optparse)
})

parse_args_or_die <- function() {
  option_list <- list(
    make_option("--module-outputs-dir", type = "character", dest = "module_outputs_dir"),
    make_option("--out", type = "character")
  )
  parse_args(OptionParser(option_list = option_list))
}

collect_module_outputs <- function(dir) stop("not implemented: read every module output table from dir")
merge_on_circrna <- function(tables) stop("not implemented: left-join all evidence onto the circRNA feature list")
assign_priority <- function(registry) stop("not implemented: transparent rule-based priority ordering (open item)")

main <- function() {
  opt <- parse_args_or_die()
  stop("candidate_registry.R is a scaffold — not implemented. See header for the intended contract.")
}

if (identical(environment(), globalenv())) main()
