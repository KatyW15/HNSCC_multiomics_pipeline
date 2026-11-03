# Usage

## Overview

This pipeline is run in two stages per batch. Stages 1a/1b/1c are unmodified,
pinned, independent nf-core pipeline invocations — not vendored into this
repo — and this pipeline (Stage 2) consumes their output directories.

The Stage 1 launch scripts live in `stage1/`: `stage1/bin/make_stage1_samplesheets.py`
splits the master sample sheet into the three nf-core sample sheets, and
`stage1/run_pipeline.sh` runs one pipeline with the settings in `stage1/conf/` and
`stage1/params/`. See `stage1/README.md`.

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

## 2. Stage 1 — nf-core/rnaseq, sarek, smrnaseq

```bash
# Split the master sheet (wgs -> sarek, rnaseq -> rnaseq, smrnaseq -> smrnaseq;
# circrnaseq rows stay for Stage 2). --patients/--batch subset it for tests.
# --sex-lookup is only needed while the master sheet has no sex column.
python3 stage1/bin/make_stage1_samplesheets.py \
  --master <master samplesheet> \
  --sex-lookup <csv with patient,sex columns> \
  --outdir stage1/samplesheets/<run_label>

# Run each pipeline (one at a time for tests)
stage1/run_pipeline.sh rnaseq   stage1/samplesheets/<run_label>/rnaseq_samplesheet.csv   <run_label>
stage1/run_pipeline.sh sarek    stage1/samplesheets/<run_label>/sarek_samplesheet.csv    <run_label>
stage1/run_pipeline.sh smrnaseq stage1/samplesheets/<run_label>/smrnaseq_samplesheet.csv <run_label>
```

Pipeline settings (versions, `--tools`, references, STAR chimeric flags) are in
`stage1/params/*.yaml`; Slurm/resource settings in `stage1/conf/*.config`.

- **Stage 1a** — nf-core/rnaseq 3.26.0, `--aligner star_salmon`, strandedness `auto`,
  STAR chimeric output via `--extra_star_align_args`.
- **Stage 1b** — nf-core/sarek 3.9.0, `--tools mutect2,strelka,ascat,cnvkit,controlfreec,manta,vep`,
  `--genome GATK.GRCh38`. ASCAT/Control-FREEC need the `sex` column.
- **Stage 1c** — nf-core/smrnaseq, version pin TBD (open item #19). Single-end: R1 only.

A single command that splits the sheet and launches all three is planned but not
written yet.

## 3. Stage 2 — this pipeline

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
