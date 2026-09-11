// TRIMGALORE — adapter/quality trimming for circRNA-seq. Trim Galore chosen
// over fastp for consistency with nf-core/circrna's own default and because the
// circRNA callers were benchmarked on Trim Galore-style trimming
// (pipeline_architecture.md §3 `CIRCRNASEQ`, decision 11).

process TRIMGALORE {
    tag "${meta.id}"
    label 'process_medium'
    container 'quay.io/biocontainers/trim-galore:0.6.10--hdfd78af_1'

    publishDir "${params.outdir}/circrnaseq/trimgalore", mode: 'copy',
        saveAs: { fn -> fn.endsWith('.fq.gz') ? null : fn }   // keep reports, not the trimmed fastqs

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path('*.fq.gz'),                       emit: reads
    tuple val(meta), path('*_trimming_report.txt'),         emit: log
    tuple val(meta), path('*.{zip,html}'), optional: true,  emit: fastqc

    script:
    def paired = reads instanceof List && reads.size() == 2
    def args   = params.trimgalore_args ?: ''
    if (paired) {
        """
        trim_galore --paired --gzip --cores ${task.cpus} ${args} ${reads[0]} ${reads[1]}
        """
    } else {
        """
        trim_galore --gzip --cores ${task.cpus} ${args} ${reads}
        """
    }

    stub:
    def paired = reads instanceof List && reads.size() == 2
    if (paired) {
        """
        touch ${meta.id}_R1_val_1.fq.gz ${meta.id}_R2_val_2.fq.gz
        touch ${meta.id}_R1.fastq.gz_trimming_report.txt ${meta.id}_R2.fastq.gz_trimming_report.txt
        """
    } else {
        """
        touch ${meta.id}_trimmed.fq.gz ${meta.id}.fastq.gz_trimming_report.txt
        """
    }
}
