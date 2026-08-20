# Output

Placeholder — expand as each subworkflow is implemented and its outputs
stabilize. Intended structure (see `pipeline_architecture.md` §4):

```
results/
├── multiqc/
├── rnaseq/{alignments,quant,differential_expression}/
├── circrnaseq/{calls,annotation,differential_expression}/
├── hpv/{linear_quant,circrna}/
├── smrnaseq/differential_expression/
├── wgs/{somatic_variants,cnv,sv,coverage_qc}/
├── integration/{mofa,clustering,cerna_network,genomic_correlation,recurrence_scores}/
└── reports/cohort_report_<run_date>.html
```
