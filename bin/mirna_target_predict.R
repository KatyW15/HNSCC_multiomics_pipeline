#!/usr/bin/env Rscript

# mirna_target_predict.R — circRNA miRNA-response-element (MRE) prediction.
#
# Purpose : Sequence-level prediction of miRNA binding sites on the detected
#           circRNAs, feeding the ceRNA network step.
# Answers : substrate for analysis_questions_master_list.md -> Supporting /
#           Mechanistic ("circRNA-miRNA sponge support").
# Inputs  : mae.rds (for the detected miRNA set); circRNA consensus calls;
#           GENCODE v50 GTF; hg38 FASTA.
# Outputs : circrna_mirna_pairs.tsv (predicted pairs + site scores),
#           circrna_sequences.fa (reconstructed mature circRNA sequences).
#
# Method:
#   - Reconstruct each circRNA's mature sequence from its BSJ + exon structure
#     (GTF), circularised (wrap the junction so sites spanning the BSJ are seen).
#   - Run MRE prediction for the detected miRNA mature sequences against the
#     circRNA sequences.
#   - OPEN ITEM (pipeline_architecture.md section 6): tool choice — miRanda,
#     RNAhybrid, or both as an agreement filter. Keep seed-match + free-energy
#     thresholds configurable.
#   - No expression filtering here — that is cerna_network.R's job.

suppressPackageStartupMessages({
  library(optparse)
  # library(Biostrings)
  # library(GenomicFeatures)
  # library(rtracklayer)
})

parse_args_or_die <- function() {
  option_list <- list(
    make_option("--mae", type = "character"),
    make_option("--circrna-calls-dir", type = "character", dest = "circrna_calls_dir"),
    make_option("--gtf", type = "character"),
    make_option("--fasta", type = "character"),
    make_option("--tool", type = "character", default = "miranda", dest = "tool"),
    make_option("--out-pairs", type = "character", dest = "out_pairs"),
    make_option("--out-sequences", type = "character", dest = "out_sequences")
  )
  parse_args(OptionParser(option_list = option_list))
}

reconstruct_circrna_sequences <- function(calls, gtf, fasta) stop("not implemented: BSJ + exon structure -> circularised mature sequence")
predict_mres <- function(circ_seqs, mirna_seqs, tool) stop("not implemented: run miRanda/RNAhybrid -> predicted circRNA-miRNA pairs")

main <- function() {
  opt <- parse_args_or_die()
  stop("mirna_target_predict.R is a scaffold — not implemented. See header for the intended contract.")
}

if (identical(environment(), globalenv())) main()
