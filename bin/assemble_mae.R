#!/usr/bin/env Rscript

# assemble_mae.R — Layer 0 of INTEGRATION.
#
# Purpose : Build one per-patient MultiAssayExperiment (MAE) from every
#           per-modality Stage-2 product. Every downstream integration module
#           reads this object.
# Answers : none directly — it is the substrate for all INTEGRATION questions
#           in analysis_questions_master_list.md.
# Inputs  : master samplesheet (patient_id, tissue, hpv_status, batch_id, ...);
#           per-modality product directories:
#             circrnaseq/  consensus BSJ calls + circRNA DE tables
#             rnaseq/      salmon host-gene counts
#             smrnaseq/    Stage 1c nf-core/smrnaseq miRNA counts (+ DE),
#                          via SMRNASEQ_ADAPTER
#             wgs/         Mutect2 n Strelka2 somatic consensus, 3-caller CNV
#                          consensus, Manta SV, mosdepth coverage QC
#             hpv/         linear E6/E7 quant, HPV-derived circRNA calls,
#                          integration sites
# Outputs : mae.rds, assembled_completeness.tsv
#
# Design notes:
#   - Missing modality for a patient => that sample is simply absent from the
#     assay's sampleMap. MAE handles this natively. Do NOT error. See
#     pipeline_architecture.md section 2 ("missing data is normal, not an error").
#   - Harmonisation done here ONCE:
#       * shared gene key = GENCODE v50 Ensembl gene IDs
#       * circRNA loci as GRanges on a single contig convention — enforce
#         chr-prefixed; rename Sarek-derived coordinates to match GENCODE
#         (architecture open item #11) BEFORE any overlap join
#       * pin the miRBase release used by Stage 1c nf-core/smrnaseq
#   - colData carries: patient_id, tissue, hpv_status, batch_id,
#     coverage_qc_pass, TMB, e6e7_load, and per-modality availability flags.
#   - SV / HPV-integration sites stored as GRangesList in metadata(), not as
#     rectangular assays.

suppressPackageStartupMessages({
  library(optparse)
  # library(MultiAssayExperiment)
  # library(SummarizedExperiment)
  # library(GenomicRanges)
  # library(DESeq2)
})

parse_args_or_die <- function() {
  option_list <- list(
    make_option("--samplesheet", type = "character"),
    make_option("--circrnaseq-dir", type = "character", dest = "circrnaseq_dir"),
    make_option("--rnaseq-dir", type = "character", dest = "rnaseq_dir"),
    make_option("--smrnaseq-dir", type = "character", dest = "smrnaseq_dir"),
    make_option("--wgs-dir", type = "character", dest = "wgs_dir"),
    make_option("--hpv-dir", type = "character", dest = "hpv_dir"),
    make_option("--gencode-version", type = "integer", default = 50L, dest = "gencode_version"),
    make_option("--mirbase-release", type = "character", default = NA_character_, dest = "mirbase_release"),
    make_option("--out-mae", type = "character", dest = "out_mae"),
    make_option("--out-completeness", type = "character", dest = "out_completeness")
  )
  parse_args(OptionParser(option_list = option_list))
}

read_circrna <- function(dir) stop("not implemented: read consensus BSJ calls + build circRNA_bsj / circRNA_cpm assays + circRNA locus GRanges")
read_rnaseq <- function(dir) stop("not implemented: read salmon host-gene counts -> gene_counts assay (GENCODE v50 Ensembl IDs)")
read_smrnaseq <- function(dir) stop("not implemented: read nf-core/smrnaseq miRNA counts -> miRNA_counts assay (pinned miRBase)")
read_wgs <- function(dir) stop("not implemented: gene-level mut_gene (binary) + cnv_gene (numeric) matrices, sv GRangesList, TMB + coverage_qc_pass per sample")
read_hpv <- function(dir) stop("not implemented: e6e7_load per sample, HPV-circRNA presence, integration-site GRangesList")
harmonise_contigs <- function(...) stop("not implemented: enforce chr-prefixed contig convention across all GRanges (open item #11)")
build_mae <- function(...) stop("not implemented: assemble MultiAssayExperiment keyed on patient_id, tolerant of absent assays")
write_completeness <- function(...) stop("not implemented: per patient x assay presence table")

main <- function() {
  opt <- parse_args_or_die()
  stop("assemble_mae.R is a scaffold — not implemented. See header for the intended contract.")
}

if (identical(environment(), globalenv())) main()
