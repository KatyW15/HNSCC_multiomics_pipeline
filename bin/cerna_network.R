#!/usr/bin/env Rscript

# cerna_network.R — circRNA-miRNA(-mRNA) ceRNA / sponge network.
#
# Purpose : Combine predicted MREs with expression evidence to propose ceRNA
#           (competing endogenous RNA) relationships.
# Answers : analysis_questions_master_list.md -> Supporting / Mechanistic
#           ("circRNA-miRNA sponge support (ceRNA hypothesis)").
# Inputs  : mae.rds (circRNA_cpm, miRNA_counts, gene_counts assays);
#           circrna_mirna_pairs.tsv from mirna_target_predict.R.
# Outputs : cerna_edges.tsv (edge list), cerna_nodes.tsv (node annotation).
#
# Method:
#   - circRNA-miRNA edge kept if: predicted MRE present AND Spearman
#     correlation across tumours is negative, with permutation-based FDR.
#   - Extend to circRNA(up)-miRNA(down)-mRNA(target, up) triads using a
#     miRNA->mRNA target database (TargetScan / miRTarBase) plus expression
#     consistency.
#   - n≈30 tumours: correlation CIs are wide. Report rho, permutation p/FDR,
#     and n per pair; treat the whole network as hypothesis-generating.

suppressPackageStartupMessages({
  library(optparse)
  # library(MultiAssayExperiment)
})

parse_args_or_die <- function() {
  option_list <- list(
    make_option("--mae", type = "character"),
    make_option("--pairs", type = "character"),
    make_option("--target-db", type = "character", default = NA_character_, dest = "target_db"),
    make_option("--fdr", type = "double", default = 0.1),
    make_option("--n-perm", type = "integer", default = 1000L, dest = "n_perm"),
    make_option("--out-edges", type = "character", dest = "out_edges"),
    make_option("--out-nodes", type = "character", dest = "out_nodes")
  )
  parse_args(OptionParser(option_list = option_list))
}

anticorrelated_pairs <- function(mae, pairs, fdr, n_perm) stop("not implemented: Spearman circRNA-miRNA across tumours + permutation FDR, keep negative")
build_triads <- function(edges, mae, target_db) stop("not implemented: circRNA-miRNA-mRNA triads via target DB + expression consistency")

main <- function() {
  opt <- parse_args_or_die()
  stop("cerna_network.R is a scaffold — not implemented. See header for the intended contract.")
}

if (identical(environment(), globalenv())) main()
