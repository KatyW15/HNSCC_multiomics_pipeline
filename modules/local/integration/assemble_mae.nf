// INTEGRATION_ASSEMBLE — Layer 0 of INTEGRATION. Builds the per-patient
// MultiAssayExperiment that every downstream integration module reads from.
// See pipeline_architecture.md §3 and bin/assemble_mae.R.
//
// Combines per-modality products keyed on patient_id, tolerant of absent
// modalities (MAE sampleMap), NOT via strict Nextflow joins — see
// pipeline_architecture.md §2. Harmonisation done here once: GENCODE v50
// Ensembl gene IDs as the shared key; circRNA loci as GRanges on a single
// contig convention (resolve open item #11 — chr-prefixed); pinned miRBase.
//
// TODO: real logic lives in bin/assemble_mae.R — this process is a scaffold.

process INTEGRATION_ASSEMBLE {
    label 'process_high'
    container 'PLACEHOLDER/bioconductor-integration'   // MultiAssayExperiment, DESeq2, GenomicRanges

    publishDir "${params.outdir}/integration/assembled", mode: 'copy'

    input:
    path samplesheet
    path circrnaseq_products, stageAs: 'circrnaseq/*'
    path rnaseq_products,     stageAs: 'rnaseq/*'
    path smrnaseq_products,   stageAs: 'smrnaseq/*'
    path wgs_products,        stageAs: 'wgs/*'
    path hpv_products,        stageAs: 'hpv/*'

    output:
    path 'mae.rds',                    emit: mae
    path 'assembled_completeness.tsv', emit: completeness

    script:
    """
    # TODO: not implemented — see bin/assemble_mae.R
    assemble_mae.R \\
        --samplesheet ${samplesheet} \\
        --circrnaseq-dir circrnaseq \\
        --rnaseq-dir rnaseq \\
        --smrnaseq-dir smrnaseq \\
        --wgs-dir wgs \\
        --hpv-dir hpv \\
        --gencode-version 50 \\
        --out-mae mae.rds \\
        --out-completeness assembled_completeness.tsv
    """

    stub:
    """
    touch mae.rds assembled_completeness.tsv
    """
}
