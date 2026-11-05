# Changelog

All notable changes to this pipeline are documented in this file.
Format based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Added
- Initial repository scaffold: directory structure, config skeletons, CI skeleton.
- Reference bundle download script (hg38 GENCODE Release 50, 8-genotype HPV panel).
- `CIRCRNASEQ` subworkflow built out (structure + module/bin scaffolds): shared
  chimeric-aware STAR pass; CIRCexplorer2 + CIRIquant + find_circ detection
  ensemble (`--circrna_tools` toggle); `PREPARE_GENOME` index/annotation builds;
  cross-tool consensus (`--circrna_min_tools`, `--circrna_bsj_merge_slop`);
  circAtlas known/novel annotation; CIRIquant count matrix; paired DESeq2;
  cross-library co-validation vs total RNA-seq chimeric junctions; RNase R
  efficiency QC. Bespoke `bin/circrna_*.R|py` steps are scaffolds
  (`-stub-run` only). Container tags and the find_circ mulled image are not yet
  pinned. See `pipeline_architecture.md` §3 + open items #1, #20–24.
- `stage1/`: launch scaffolding for the three Stage 1 nf-core pipelines (sarek,
  rnaseq, smrnaseq). `bin/make_stage1_samplesheets.py` splits the master sample
  sheet into the three nf-core sample sheets; `run_pipeline.sh` runs one pipeline
  with shared Alpine settings (`conf/alpine.config`, `env/alpine_env.sh`) plus
  per-pipeline overrides (`conf/*.config`) and parameters (`params/*.yaml`).
  Values still to fill in are marked TODO; the all-in-one launcher is not
  written yet.
- `--smrnaseq_results` param (Stage 1c nf-core/smrnaseq output dir).

### Changed
- smRNA-seq moved to Stage 1 (nf-core/smrnaseq): `SMRNASEQ` stub replaced by
  `SMRNASEQ_ADAPTER`, which ingests the Stage 1c output instead of running its
  own alignment/miRDeep2, matching `WGS_ADAPTER` / `RNASEQ_ADAPTER`.
- `INPUT_CHECK` treats `NA` like blank in `sample_id`/`fastq_1`/`fastq_2`, and a
  row is "missing" when `fastq_1` is blank/NA (its `sample_id` may stay filled
  in), so the master sample sheet's documented missing rows pass validation.
- `conf/slurm.config`: QoS `normal` -> `cpu-normal` (Alpine's QoS name);
  `process_high` runs on `cpu-long`; submit rate matches Stage 1.

Nothing tagged yet — no released version exists.
