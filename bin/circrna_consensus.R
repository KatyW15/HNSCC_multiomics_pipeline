#!/usr/bin/env Rscript

# circrna_consensus.R — per-sample cross-tool BSJ consensus.
#
# Purpose : Merge the CIRCexplorer2 / CIRIquant / find_circ BSJ call sets for
#           one library into a single table, recording how many (and which)
#           tools support each junction.
# Answers : pipeline_architecture.md §3 `CIRCRNASEQ`, open item #1.
# Inputs  : --sample      sample id
#           --tool-beds   space-separated tool=path entries (normalised BSJ BEDs:
#                         chrom,start,end,name,bsj_reads,strand)
#           --fasta       hg38 FASTA (+ .fai alongside) for the GT/AG check
#           --merge-slop  coordinate margin in bp for matching BSJs across
#                         tools (default 5); canonical junctions must match
#                         exactly
#           --min-bsj-reads  drop a per-tool call below this support before
#                            merging (default 2)
# Output  : --out  <sample>.consensus_bsj.tsv with columns
#             chrom, start, end, strand, bsj_reads (max across supporting tools),
#             bsj_reads_by_tool (json-ish), n_tools, tools, canonical_motif
#
# Method:
#   - read each tool BED, filter to >= min-bsj-reads.
#   - cluster BSJs across tools: exact-match key (chrom,start,end,strand);
#     then a second pass merges clusters whose ends are all within merge-slop
#     AND that are non-canonical (canonical stay exact to avoid over-merging
#     real neighbouring circRNAs).
#   - per cluster: n_tools, sorted tool list, per-tool read counts, max reads.
#   - canonical_motif = donor GT + acceptor AG at the junction (Biostrings on
#     the FASTA); ADVISORY only — nothing is dropped on it here.
#   - NOTE: every >=1-tool cluster is written out. The >=2-tool restriction is
#     applied downstream (CIRCRNA_QUANT_MATRIX), not here.

suppressPackageStartupMessages({
  library(optparse)
  # library(GenomicRanges)
  # library(Biostrings)
  # library(data.table)
})

parse_args_or_die <- function() {
  option_list <- list(
    make_option("--sample", type = "character"),
    make_option("--tool-beds", type = "character", dest = "tool_beds"),
    make_option("--fasta", type = "character"),
    make_option("--merge-slop", type = "integer", default = 5L, dest = "merge_slop"),
    make_option("--min-bsj-reads", type = "integer", default = 2L, dest = "min_bsj_reads"),
    make_option("--out", type = "character")
  )
  parse_args(OptionParser(option_list = option_list))
}

read_tool_beds   <- function(spec, min_reads) stop("not implemented: parse tool=path list, read normalised BSJ BEDs, filter to min_reads")
cluster_bsjs     <- function(bsj_list, slop) stop("not implemented: exact-match clustering + slop merge for non-canonical only")
canonical_motif  <- function(clusters, fasta) stop("not implemented: GT/AG donor/acceptor check via Biostrings (advisory flag)")
write_consensus  <- function(clusters, path) stop("not implemented: write per-sample consensus table (all >=1-tool clusters)")

main <- function() {
  opt <- parse_args_or_die()
  stop("circrna_consensus.R is a scaffold — not implemented. See header for the intended contract.")
}

if (identical(environment(), globalenv())) main()
