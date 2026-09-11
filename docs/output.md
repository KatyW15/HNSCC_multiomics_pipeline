# Output

Placeholder — expand as each subworkflow is implemented and its outputs
stabilize. Intended structure (see `pipeline_architecture.md` §4):

```
results/
├── multiqc/
├── rnaseq/{alignments,quant,differential_expression}/
├── circrnaseq/
│   ├── reference/                # built indices + normalised circAtlas assets
│   ├── fastqc/  trimgalore/  star/
│   ├── calls/{circexplorer2,ciriquant,find_circ}/   # per-tool BSJ beds
│   ├── consensus/               # per-sample cross-tool consensus (n_tools)
│   ├── annotation/              # circrna_annotated.tsv, circrna_candidates.tsv
│   ├── quantification/          # circRNA_bsj / circRNA_cpm matrices, linear ratio
│   ├── differential_expression/ # paired DESeq2 tables
│   └── qc/                      # rnase_r_efficiency.tsv (+ MultiQC section)
├── hpv/{linear_quant,circrna}/
├── smrnaseq/differential_expression/
├── wgs/{somatic_variants,cnv,sv,coverage_qc}/
├── integration/
│   ├── assembled/                # mae.rds + assembled_completeness.tsv
│   ├── recurrence_scores/        # DE tables + commonality columns
│   ├── cerna_network/            # circRNA–miRNA(–mRNA) edges/nodes
│   ├── genomic_correlation/      # circRNA loci/burden vs CNV/SV/TMB/HPV-integration
│   ├── hpv_axis/                 # HPV-derived circRNA specificity, E6/E7 load
│   ├── structure/                # per-modality + iClusterBayes clustering, ARI matrix
│   ├── biomarker/                # nested-CV candidate circRNA panel
│   └── candidate_registry.tsv    # cross-module priority table
└── reports/cohort_report_<run_date>.html
```
