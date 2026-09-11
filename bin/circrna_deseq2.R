#!/usr/bin/env Rscript

# circrna_deseq2.R — paired differential circRNA expression.
#
# Purpose : Confirmatory circRNA DE, in the SAME model form as the host-gene
#           and miRNA DESeq2 runs so INTEGRATION_RECURRENCE can stack the
#           output tables.
# Answers : pipeline_architecture.md §3 `CIRCRNASEQ` (decisions 18 & 19),
#           open items #17 & #20; Q1 / Q2.
# Inputs  : --counts           circrna_bsj_counts.tsv (circ_id x sample raw BSJ)
#           --annotated        circrna_annotated.tsv (host gene / known flag —
#                              merged onto the result tables)
#           --samplesheet      master sample sheet (patient_id, tissue,
#                              hpv_status)
#           --design           model formula (default
#                              '~ patient + hpv_status + tissue + hpv_status:tissue')
#           --drop-unpaired     drop patients lacking a matched normal (decision 18)
#           --sizefactor-method 'poscounts' (placeholder — open item #20) |
#                               'ratio' | 'import:<file>'
#           --min-reads / --min-samples-frac  low-count prefilter (decision 19:
#                              >= min-reads in >= min-samples-frac of samples in
#                              at least one tissue group)
#           --contrasts        comma list; 'tumor_vs_normal', 'hpv_interaction'
#           --outprefix        output prefix
# Outputs : <outprefix>.<contrast>.tsv, <outprefix>.dds.rds,
#           <outprefix>.sizefactors.tsv
#
# Method:
#   - build colData from the sample sheet; restrict to circrnaseq libraries;
#     if --drop-unpaired, keep only patients with both tumor and normal.
#   - prefilter circRNAs on the per-tissue-group detection rule above.
#   - DESeqDataSetFromMatrix with the given design; estimateSizeFactors with
#     the chosen method; DESeq().
#   - extract each requested contrast (tumor_vs_normal = tissue main effect at
#     hpv reference; hpv_interaction = hpv_status:tissue term); shrink LFCs
#     (apeglm/ashr); merge host_gene / known from --annotated; write.

suppressPackageStartupMessages({
  library(optparse)
  # library(DESeq2)
  # library(data.table)
})

parse_args_or_die <- function() {
  option_list <- list(
    make_option("--counts", type = "character"),
    make_option("--annotated", type = "character"),
    make_option("--samplesheet", type = "character"),
    make_option("--design", type = "character",
                default = "~ patient + hpv_status + tissue + hpv_status:tissue"),
    make_option("--drop-unpaired", action = "store_true", default = FALSE, dest = "drop_unpaired"),
    make_option("--sizefactor-method", type = "character", default = "poscounts", dest = "sizefactor_method"),
    make_option("--min-reads", type = "integer", default = 2L, dest = "min_reads"),
    make_option("--min-samples-frac", type = "double", default = 0.25, dest = "min_samples_frac"),
    make_option("--contrasts", type = "character", default = "tumor_vs_normal,hpv_interaction"),
    make_option("--outprefix", type = "character")
  )
  parse_args(OptionParser(option_list = option_list))
}

build_coldata   <- function(samplesheet, drop_unpaired) stop("not implemented: circrnaseq colData, optional paired-only restriction")
prefilter_circ  <- function(counts, coldata, min_reads, min_frac) stop("not implemented: per-tissue-group detection-rate prefilter")
run_deseq       <- function(counts, coldata, design, sf_method) stop("not implemented: DESeqDataSet + size factors + DESeq()")
extract_contrast <- function(dds, name) stop("not implemented: tumor_vs_normal / hpv_interaction extraction + LFC shrink")

main <- function() {
  opt <- parse_args_or_die()
  stop("circrna_deseq2.R is a scaffold — not implemented. See header for the intended contract.")
}

if (identical(environment(), globalenv())) main()
