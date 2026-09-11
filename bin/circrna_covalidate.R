#!/usr/bin/env Rscript

# circrna_covalidate.R — cross-library BSJ co-validation (Q1d).
#
# Purpose : Flag which RNase R-derived consensus circRNAs are independently
#           seen as chimeric (back-splice) junctions in the matched total
#           RNA-seq libraries.
# Answers : pipeline_architecture.md §3 `CIRCRNASEQ`, open items #10 & #23.
# Inputs  : --annotated     circrna_annotated.tsv
#           --chimeric-dir  dir of STAR Chimeric.out.junction files from the
#                           Stage 1a nf-core/rnaseq run (via RNASEQ_ADAPTER);
#                           may be EMPTY (adapter not wired yet)
#           --match-slop    bp tolerance for matching a BSJ to a chimeric
#                           junction (default 5)
# Output  : --out  circrna_candidates.tsv = the annotated table plus
#             validated_in_totalRNA (TRUE / FALSE / NA if no chimeric input),
#             chimeric_reads (summed supporting reads across total-RNA libs),
#             n_totalRNA_libs_supporting
#
# Method:
#   - if --chimeric-dir is empty: copy annotated through, set the new columns
#     to NA, exit 0 (documented tolerant behaviour).
#   - else: parse each Chimeric.out.junction, keep back-splice-consistent rows
#     (donor downstream of acceptor, same chrom/strand), aggregate reads per
#     junction.
#   - match each consensus BSJ to chimeric junctions within --match-slop on
#     both breakpoints; record support.

suppressPackageStartupMessages({
  library(optparse)
  # library(data.table)
  # library(GenomicRanges)
})

parse_args_or_die <- function() {
  option_list <- list(
    make_option("--annotated", type = "character"),
    make_option("--chimeric-dir", type = "character", dest = "chimeric_dir"),
    make_option("--match-slop", type = "integer", default = 5L, dest = "match_slop"),
    make_option("--out", type = "character")
  )
  parse_args(OptionParser(option_list = option_list))
}

read_chimeric_dir <- function(dir) stop("not implemented: parse STAR Chimeric.out.junction, keep back-splice rows, aggregate reads")
match_bsjs        <- function(annotated, chimeric, slop) stop("not implemented: slop match on both breakpoints -> support columns")
passthrough_na    <- function(annotated, out) stop("not implemented: copy annotated + NA columns when no chimeric input")

main <- function() {
  opt <- parse_args_or_die()
  stop("circrna_covalidate.R is a scaffold — not implemented. See header for the intended contract.")
}

if (identical(environment(), globalenv())) main()
