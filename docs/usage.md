# Usage

## Overview

This pipeline is run in three stages per batch. Stages 1a/1b are unmodified,
pinned, independent nf-core pipeline invocations — not vendored into this
repo — and this pipeline (Stage 2) consumes their output directories.

## 1. Sample sheet

One row per (patient × tissue × modality). Template: `assets/samplesheet_template.csv`.

Controlled vocabulary (validated at input, not free text):
- `tissue`: `tumor` | `normal`
- `modality`: `rnaseq` (ribo-depleted) | `circrnaseq` (RNase R-treated) | `smrnaseq` | `wgs`
- `hpv_status`: `positive` | `negative` | `unknown`
- `hpv_genotype`: `HPV16` | `HPV18` | `other_highrisk` | `NA`

Missing modalities are expected, not an error — leave `sample_id`/`fastq_1`/`fastq_2`
blank for a patient/tissue/modality combination that wasn't generated, and note why
in the `notes` column.

## 2. Stage 1a — nf-core/rnaseq

```bash
nextflow run nf-core/rnaseq -r 3.26.0 \
  -profile singularity \
  --input <rnaseq-only samplesheet derived from the master sheet> \
  --aligner star_salmon \
  --extra_star_align_args '--chimOutType Junctions --chimSegmentMin 12 --chimJunctionOverhangMin 12' \
  --outdir <stage1a_outdir>
```

Strandedness: `auto`.

## 3. Stage 1b — nf-core/sarek

```bash
nextflow run nf-core/sarek -r 3.9.0 \
  -profile singularity \
  --input <wgs-only samplesheet derived from the master sheet> \
  --tools mutect2,ascat,cnvkit,controlfreec,manta,vep \
  --genome GATK.GRCh38 \
  --outdir <stage1b_outdir>
```

## 4. Stage 2 — this pipeline

```bash
nextflow run . \
  -profile slurm \
  --samplesheet <master samplesheet> \
  --rnaseq_results <stage1a_outdir> \
  --sarek_results <stage1b_outdir> \
  --fasta <hg38 fasta> \
  --gtf <GENCODE v50 gtf> \
  --hpv_panel_fasta <hpv panel fasta> \
  --circrna_annotation <pinned circAtlas hg38 release> \
  --outdir <results dir>
```

### circRNA arm (CIRCRNASEQ)

Requires `--fasta`, `--gtf`, and `--circrna_annotation` (pinned circAtlas hg38
release). Per-aligner indices are built on first run unless supplied via
`--star_index` / `--bwa_index` / `--bowtie2_index` / `--ciriquant_index`
(recommended on the HPC — build once, reuse across batches).

Key knobs (defaults in `nextflow.config`, full list in `nextflow_schema.json`):
- `--circrna_tools circexplorer2,ciriquant,find_circ` — detection ensemble;
  drop entries to disable a caller. Without `ciriquant` the count matrix and
  DESeq2 steps are skipped (it is the uniform quantifier).
- `--circrna_bsj_min_reads 2`, `--circrna_min_tools 2`,
  `--circrna_bsj_merge_slop 5` — consensus/filtering rules.
- `--star_chimeric_args '...'` — must match the Stage 1a nf-core/rnaseq
  `--extra_star_align_args` for the cross-library co-validation to be
  meaningful (see `pipeline_architecture.md` open items #10, #23).

See `pipeline_architecture.md` §3 `CIRCRNASEQ` for the full design and open
items #1, #20–24.

## Adding a new batch

Add new rows to the master sample sheet (new `batch_id`) rather than creating
a separate sheet. Re-run all three stages against the cumulative sheet —
Nextflow's `-resume` caching means only new samples and joint/integration
steps actually recompute. See `pipeline_architecture.md` for the rationale.

## Implementation status

- `INPUT_CHECK` — built.
- `CIRCRNASEQ` — subworkflow + module structure built; the bespoke steps
  (`bin/circrna_*.R|py`, `bin/rnaser_efficiency.py`) are scaffolds that exit
  with "not implemented". Runs end to end only under `-stub-run`. Container
  tags and the find_circ mulled image still need pinning
  (`pipeline_architecture.md` §5, open item #22).
- All other subworkflows (§3 of `pipeline_architecture.md`) — stubbed.

See that document's implementation order before expecting a full run to
produce results.
