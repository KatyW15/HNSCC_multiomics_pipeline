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

Four pipeline invocations per batch:

1. **Stage 1a** — [`nf-core/rnaseq`](https://github.com/nf-core/rnaseq) `v3.26.0`, run against
   the ribo-depleted total RNA-seq samples.
2. **Stage 1b** — [`nf-core/sarek`](https://github.com/nf-core/sarek) `v3.9.0`, run against
   the WGS samples.
3. **Stage 1c** — [`nf-core/smrnaseq`](https://github.com/nf-core/smrnaseq) (version pin TBD),
   run against the smRNA-seq samples.
4. **Stage 2** — this pipeline. Takes the Stage 1 output directories plus the master
   sample sheet, and handles circRNA-seq, HPV detection, and all cross-omics
   integration/reporting.

None of the Stage 1 pipelines is vendored here — they're run as their own pinned, independent
invocations. `stage1/` holds the scripts that split the master sample sheet and launch them
(see `stage1/README.md`). This pipeline consumes their output directories as input parameters.

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
  --smrnaseq_results /path/to/stage1c_nf-core-smrnaseq/results \
  --outdir /path/to/results
```

See `docs/usage.md` for sample sheet format and full parameter reference.

## License

MIT — see `LICENSE`.
