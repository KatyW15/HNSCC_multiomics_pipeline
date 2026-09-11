# circRNA annotation assets

Drop the **pinned circAtlas hg38 release** here and point `--circrna_annotation`
at it (or set a default in `nextflow.config`).

`PREPARE_GENOME` → `CIRCRNA_ANNOTATION_PREP` (`bin/circrna_annotation_prep.R`)
normalises it into:

- `known_circ.hg38.bed` — known-circRNA BED, `chr`-prefixed contigs
- `circrna_annotation.gtf` — circRNA annotation GTF for CIRCexplorer2 / host-gene calls

Both are written to `results/circrnaseq/reference/` at runtime.

## To pin (open item #16 / #11 in `pipeline_architecture.md`)

- Record the exact circAtlas version + download URL + date + checksum below.
- Confirm the build is hg38 (no silent liftOver — `circrna_annotation_prep.R`
  fails loudly otherwise).
- Keep the contig convention consistent with the Sarek / GENCODE bundle
  (`chr`-prefixed).

| field | value |
|-------|-------|
| circAtlas version | _TBD_ |
| source URL | _TBD_ |
| downloaded | _TBD_ |
| sha256 | _TBD_ |
