#!/usr/bin/env Rscript

# circrna_annotation_prep.R — normalise the pinned circAtlas hg38 release.
#
# Purpose : One-time reference prep for the circRNA arm — turn the raw circAtlas
#           download into (a) a known-circRNA BED and (b) a circRNA annotation
#           GTF, both on the chr-prefixed contig convention shared with the
#           Sarek / GENCODE bundle.
# Answers : pipeline_architecture.md open items #11 (contig naming) and #16
#           (pin the release); §3 `CIRCRNASEQ` PREPARE_GENOME.
# Inputs  : --circatlas  raw circAtlas release (BED/CSV/GTF as distributed)
#           --gtf        GENCODE v50 annotation (for host-gene cross-checks)
#           --contig-style  'chr' (default) — target contig convention
# Outputs : --out-bed  known_circ.hg38.bed  (chrom,start,end,circ_id,score,strand)
#           --out-gtf  circrna_annotation.gtf
#
# Method:
#   - parse circAtlas coordinates; lift/standardise to hg38 if the release
#     carries a different build (fail loudly if it does — no silent liftOver).
#   - harmonise seqlevels to `chr` prefix; drop scaffolds not in the GENCODE
#     primary assembly.
#   - collapse duplicate BSJ coordinates; keep the circAtlas ID + tissue count.
#   - emit the annotation GTF (exon blocks per circRNA where the release
#     provides them, else single-block).

suppressPackageStartupMessages({
  library(optparse)
  # library(rtracklayer)
  # library(GenomicRanges)
})

parse_args_or_die <- function() {
  option_list <- list(
    make_option("--circatlas", type = "character"),
    make_option("--gtf", type = "character"),
    make_option("--contig-style", type = "character", default = "chr", dest = "contig_style"),
    make_option("--out-bed", type = "character", dest = "out_bed"),
    make_option("--out-gtf", type = "character", dest = "out_gtf")
  )
  parse_args(OptionParser(option_list = option_list))
}

read_circatlas       <- function(path) stop("not implemented: parse circAtlas release, verify hg38 build")
harmonise_seqlevels  <- function(gr, style) stop("not implemented: enforce chr-prefixed contig convention, drop non-primary scaffolds")
write_known_bed      <- function(gr, path) stop("not implemented: write known-circRNA BED (circ_id + tissue count in score)")
write_annotation_gtf <- function(gr, path) stop("not implemented: write circRNA annotation GTF (exon blocks where available)")

main <- function() {
  opt <- parse_args_or_die()
  stop("circrna_annotation_prep.R is a scaffold — not implemented. See header for the intended contract.")
}

if (identical(environment(), globalenv())) main()
