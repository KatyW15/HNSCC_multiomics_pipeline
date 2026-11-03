#!/bin/bash
# Run ONE Stage 1 nf-core pipeline. Used directly for single-pipeline tests; the
# master launcher (not written yet) will call this once per pipeline.
#
#   usage: run_pipeline.sh <sarek|rnaseq|smrnaseq> <samplesheet.csv> <run_label>
#   e.g.:  run_pipeline.sh rnaseq samplesheets/test/rnaseq_samplesheet.csv test
#
# <run_label> keeps test and real runs apart (e.g. "test", "cohort"). Reuse the same
# label for every new batch so -resume finds the cached work from earlier batches.
# Override LAUNCH_DIR / WORK_DIR / OUTDIR in the environment to point at an existing
# run (e.g. the batch-1 sarek run, whose cache lives in .../HNSCC_analysis/scripts).
set -euo pipefail

if [[ $# -ne 3 ]]; then
    echo "usage: $0 <sarek|rnaseq|smrnaseq> <samplesheet.csv> <run_label>" >&2
    exit 1
fi
PIPELINE=$1
SAMPLESHEET=$(realpath "$2")
RUN_LABEL=$3

STAGE1_DIR=$(cd "$(dirname "$0")" && pwd)
source "$STAGE1_DIR/env/alpine_env.sh"

case "$PIPELINE" in
    sarek)    VERSION=3.9.0;  RESULTS_NAME=1_WGS ;;
    rnaseq)   VERSION=3.26.0; RESULTS_NAME=2_totalRNAseq ;;
    smrnaseq) VERSION=TODO;   RESULTS_NAME=4_smRNAseq ;;   # open item #19
    *) echo "unknown pipeline: $PIPELINE" >&2; exit 1 ;;
esac
if [[ $VERSION == TODO ]]; then
    echo "$PIPELINE version not pinned yet -- set it in $0" >&2
    exit 1
fi

# The launch dir holds .nextflow/ (the -resume cache) and .nextflow.log; each
# pipeline needs its own so they can run side by side.
: "${LAUNCH_DIR:=$HNSCC_PROJECTS/launch/$PIPELINE/$RUN_LABEL}"
: "${WORK_DIR:=$HNSCC_SCRATCH/work/$PIPELINE/$RUN_LABEL}"
: "${OUTDIR:=$HNSCC_SCRATCH/$RESULTS_NAME/$RUN_LABEL}"
mkdir -p "$LAUNCH_DIR" "$WORK_DIR" "$OUTDIR"
cd "$LAUNCH_DIR"

echo "pipeline:    nf-core/$PIPELINE $VERSION"
echo "samplesheet: $SAMPLESHEET"
echo "launch dir:  $LAUNCH_DIR"
echo "work dir:    $WORK_DIR"
echo "outdir:      $OUTDIR"
nextflow -version

nextflow run "nf-core/$PIPELINE" -r "$VERSION" \
    -profile singularity \
    -c "$STAGE1_DIR/conf/alpine.config" \
    -c "$STAGE1_DIR/conf/$PIPELINE.config" \
    -params-file "$STAGE1_DIR/params/$PIPELINE.yaml" \
    -w "$WORK_DIR" \
    --input "$SAMPLESHEET" \
    --outdir "$OUTDIR" \
    -resume
