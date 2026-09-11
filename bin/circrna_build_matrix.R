#!/usr/bin/env Rscript

# circrna_build_matrix.R — cohort circRNA count / CPM matrices.
#
# Purpose : Assemble the quantified circRNA matrices for DE and for the
#           INTEGRATION MAE, from the per-sample CIRIquant GTFs, restricted to
#           the DE-eligible BSJ set.
# Answers : pipeline_architecture.md §3 `CIRCRNASEQ` (decisions 4 & 7),
#           open items #20 & #24.
# Inputs  : --ciriquant-dir  dir of <sample>/<sample>.gtf CIRIquant outputs
#           --annotated      circrna_annotated.tsv (carries max_n_tools)
#           --samplesheet    master sample sheet (for column order / sample ids)
#           --min-tools      keep only BSJs with max_n_tools >= this (default 2)
# Outputs : --out-counts  circrna_bsj_counts.tsv  (circ_id x sample, raw BSJ reads)
#           --out-cpm     circrna_cpm.tsv         (CIRIquant CPM)
#           --out-ratio   circrna_linear_ratio.tsv (long: circ_id, sample,
#                                                   junction_ratio)
#
# Method:
#   - parse each CIRIquant GTF: circ_id, bsj reads, cpm, junction_ratio.
#   - eligible BSJ set = annotated rows with max_n_tools >= min-tools
#     INTERSECT circ_ids CIRIquant actually reported (v1 limitation — see
#     open item #24; provided-BED re-quant would lift the intersect).
#   - build circ_id x sample matrices, 0-fill BSJs a sample's CIRIquant did
#     not report, column order from the sample sheet.
#   - emit raw counts (for DESeq2) and CPM (for the MAE circRNA_cpm assay);
#     ratio table stays long.

suppressPackageStartupMessages({
  library(optparse)
  # library(data.table)
})

parse_args_or_die <- function() {
  option_list <- list(
    make_option("--ciriquant-dir", type = "character", dest = "ciriquant_dir"),
    make_option("--annotated", type = "character"),
    make_option("--samplesheet", type = "character"),
    make_option("--min-tools", type = "integer", default = 2L, dest = "min_tools"),
    make_option("--out-counts", type = "character", dest = "out_counts"),
    make_option("--out-cpm", type = "character", dest = "out_cpm"),
    make_option("--out-ratio", type = "character", dest = "out_ratio")
  )
  parse_args(OptionParser(option_list = option_list))
}

parse_ciriquant_gtf <- function(path) stop("not implemented: extract circ_id / bsj / cpm / junction_ratio from a CIRIquant GTF")
eligible_bsjs       <- function(annotated, min_tools, reported_ids) stop("not implemented: max_n_tools >= min_tools INTERSECT CIRIquant-reported ids")
build_matrices      <- function(per_sample, bsj_ids, sample_order) stop("not implemented: circ_id x sample count + CPM matrices, 0-filled")

main <- function() {
  opt <- parse_args_or_die()
  stop("circrna_build_matrix.R is a scaffold — not implemented. See header for the intended contract.")
}

if (identical(environment(), globalenv())) main()
