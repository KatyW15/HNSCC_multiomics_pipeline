#!/usr/bin/env python3

# rnaser_efficiency.py — RNase R treatment-efficiency QC metric.
#
# Purpose : Per-library metric for how completely linear RNA was digested, so a
#           failed RNase R prep is visible before it confounds every
#           circular/linear comparison downstream.
# Answers : pipeline_architecture.md §3 `CIRCRNASEQ` (decision 14).
# Inputs  : --star-counts-dir  dir of STAR <sample>.ReadsPerGene.out.tab
#           --gtf              GENCODE v50 annotation (to classify features)
#           --samplesheet      master sample sheet (sample ids / tissue)
# Outputs : --out      rnase_r_efficiency.tsv
#                        sample, linear_fraction, n_reads_linear_only,
#                        n_reads_total, rnase_r_pass
#           --out-mqc  rnase_r_efficiency_mqc.tsv  (MultiQC custom-content:
#                        a header block + the same table)
#
# Method (scaffold — exact definition still open):
#   - "linear-only" reference set = multi-exon housekeeping transcripts whose
#     internal exons cannot appear in a back-splice product, plus purely
#     intronic intervals. Signal there should be strongly depleted by RNase R.
#   - linear_fraction = reads in the linear-only set / total assigned reads.
#   - rnase_r_pass = linear_fraction <= threshold (placeholder; set from the
#     batch-1 distribution, same "decide against real data" note as the
#     min-expression threshold, open item #16).

import argparse
import sys


def parse_args(argv=None):
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--star-counts-dir", required=True, dest="star_counts_dir")
    p.add_argument("--gtf", required=True)
    p.add_argument("--samplesheet", required=True)
    p.add_argument("--out", required=True)
    p.add_argument("--out-mqc", required=True, dest="out_mqc")
    p.add_argument("--pass-threshold", type=float, default=0.10, dest="pass_threshold")
    return p.parse_args(argv)


def build_linear_only_set(gtf_path):
    raise NotImplementedError(
        "linear-only reference set (multi-exon housekeeping internal exons + intronic intervals)"
    )


def score_sample(counts_tab, linear_only):
    raise NotImplementedError("linear_fraction = linear-only reads / total assigned reads")


def write_mqc(rows, path):
    raise NotImplementedError("MultiQC custom-content header + table")


def main(argv=None):
    _opt = parse_args(argv)
    sys.exit(
        "rnaser_efficiency.py is a scaffold — not implemented. See header for the intended contract."
    )


if __name__ == "__main__":
    main()
