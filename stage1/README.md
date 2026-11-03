# Stage 1: nf-core/sarek, rnaseq, smrnaseq

Runs the three pinned nf-core pipelines from the master samplesheet. Stage 2
(the rest of this repo) is not involved yet. The master samplesheet itself is not
committed; it lives in the HNSCC_pipeline_build planning folder / on Alpine.

```
stage1/
├── bin/make_stage1_samplesheets.py   master sheet -> 3 nf-core samplesheets
├── run_pipeline.sh                   run ONE pipeline (tests; called by the launcher later)
├── env/alpine_env.sh                 modules, NXF_*, tmp + container cache dirs
├── conf/alpine.config                shared Slurm/Singularity settings
├── conf/{sarek,rnaseq,smrnaseq}.config   per-pipeline process overrides
└── params/{sarek,rnaseq,smrnaseq}.yaml   per-pipeline parameters (-params-file)
```

Single-pipeline test on Alpine:

```bash
python3 bin/make_stage1_samplesheets.py \
    --master /path/to/master_samplesheet.csv \
    --sex-lookup /path/to/stage1_sarek_samplesheet_with_sex.csv \
    --patients TP00471 --check-files \
    --outdir samplesheets/test        # git-ignored
./run_pipeline.sh rnaseq samplesheets/test/rnaseq_samplesheet.csv test
```

## Still to fill in (search for TODO)

- `conf/alpine.config`: replace with the validated `curc_alpine.config` from the cluster
- `conf/sarek.config`: SMTP-fix path, Manta settings
- `params/rnaseq.yaml`: fasta/gtf paths; star/salmon index paths after the first run
- `params/smrnaseq.yaml` + `run_pipeline.sh`: version pin, protocol (library kit), miRBase release
- `env/alpine_env.sh`: one container cache location; head-node heap size
- launcher: not written yet (Slurm quotas: 1,000 cpu-normal / 200 cpu-long)
