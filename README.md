# HNSCC_multiomics_pipeline

Nextflow (DSL2) pipeline for multi-omics profiling of paired tumor/normal HNSCC samples
(RNA-seq, circRNA-seq, smRNA-seq, WGS), with an emphasis on circRNA biomarker discovery
and HPV-status-stratified analysis. Built for reproducible, incremental batch processing
as new patient cohorts are collected.

Design rationale and open decisions are tracked in `pipeline_architecture.md` (workshop
document, not shipped as part of the pipeline itself) and the master analysis question
list in the accompanying `HNSCC_pipeline_build` planning folder.

## Status

Scaffolding stage — directory structure and config skeletons are in place; subworkflow
logic is not yet implemented. See `docs/usage.md` for the intended run pattern.

## Pipeline architecture, in brief

Three pipeline invocations per batch:

1. **Stage 1a** — [`nf-core/rnaseq`](https://github.com/nf-core/rnaseq) `v3.26.0`, run against
   the ribo-depleted total RNA-seq samples.
2. **Stage 1b** — [`nf-core/sarek`](https://github.com/nf-core/sarek) `v3.9.0`, run against
   the WGS samples.
3. **Stage 2** — this pipeline. Takes both Stage 1 output directories plus the master
   sample sheet, and handles circRNA-seq, smRNA-seq, HPV detection, and all cross-omics
   integration/reporting.

Neither Stage 1 pipeline is vendored here — they're run as their own pinned, independent
invocations. This pipeline consumes their output directories as input parameters.

## Requirements

- Nextflow (DSL2)
- Singularity/Apptainer
- Slurm (see `conf/slurm.config`)

## Quick start

```bash
nextflow run . \
  -profile slurm \
  --samplesheet /path/to/master_samplesheet.csv \
  --rnaseq_results /path/to/stage1a_nf-core-rnaseq/results \
  --sarek_results /path/to/stage1b_nf-core-sarek/results \
  --outdir /path/to/results
```

See `docs/usage.md` for sample sheet format and full parameter reference.

## License

MIT — see `LICENSE`.
