#!/usr/bin/env Rscript

# circrna_annotate.R — cohort-level annotation of consensus BSJs.
#
# Purpose : Pool per-sample consensus tables into one cohort circRNA set and
#           annotate host gene, circRNA type, and known/novel status.
# Answers : pipeline_architecture.md §3 `CIRCRNASEQ` (decisions 15-17), Q1e.
# Inputs  : --consensus-dir  dir of <sample>.consensus_bsj.tsv
#           --gtf            GENCODE v50 annotation GTF (same file as
#                            RNASEQ_ADAPTER — needed for the circ/linear join)
#           --known-circ     pinned circAtlas hg38 known-circRNA BED
# Outputs : --out-table  circrna_annotated.tsv — one row per distinct BSJ:
#             circ_id, chrom, start, end, strand, host_gene, gene_id,
#             circ_type (exonic/intronic/intergenic/antisense), known,
#             circatlas_id, n_samples, max_n_tools, per_sample_n_tools,
#             per_sample_bsj_reads
#           --out-bed    circrna_cohort_bsj.bed — the union BSJ set
#
# Method:
#   - union of BSJ coordinates across all samples (chrom,start,end,strand);
#     carry per-sample n_tools + read counts as packed columns.
#   - host gene: overlap the BSJ span with GENCODE exons (GenomicFeatures
#     TxDb); circ_type from exon/intron/intergenic containment; antisense if
#     the only overlap is on the opposite strand.
#   - known: exact (or +-2 bp) match to a circAtlas entry -> known + its id;
#     else novel.
#   - circ_id = chrom:start-end:strand (stable key used everywhere downstream,
#     incl. the INTEGRATION MAE circRNA_bsj assay rownames).

suppressPackageStartupMessages({
  library(optparse)
  # library(GenomicFeatures)
  # library(GenomicRanges)
  # library(rtracklayer)
  # library(data.table)
})

parse_args_or_die <- function() {
  option_list <- list(
    make_option("--consensus-dir", type = "character", dest = "consensus_dir"),
    make_option("--gtf", type = "character"),
    make_option("--known-circ", type = "character", dest = "known_circ"),
    make_option("--out-table", type = "character", dest = "out_table"),
    make_option("--out-bed", type = "character", dest = "out_bed")
  )
  parse_args(OptionParser(option_list = option_list))
}

pool_consensus   <- function(dir) stop("not implemented: read + union per-sample consensus tables, pack per-sample stats")
annotate_host    <- function(bsj, gtf) stop("not implemented: host gene + circ_type from GENCODE exons/introns")
flag_known       <- function(bsj, known_bed) stop("not implemented: circAtlas exact/+-2bp match -> known + circatlas_id")
write_outputs    <- function(annotated, out_table, out_bed) stop("not implemented: write annotated TSV + cohort BSJ BED")

main <- function() {
  opt <- parse_args_or_die()
  stop("circrna_annotate.R is a scaffold — not implemented. See header for the intended contract.")
}

if (identical(environment(), globalenv())) main()
