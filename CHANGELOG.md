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

Nothing tagged yet — no released version exists.
