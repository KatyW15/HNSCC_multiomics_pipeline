// CIRIQUANT — BWA-arm BSJ detection (runs CIRI2 internally) AND the uniform
// quantifier for the whole ensemble: its per-sample GTF carries BSJ counts,
// CPM, and the circular/linear junction ratio. See pipeline_architecture.md §3
// `CIRCRNASEQ` (decisions 2 & 4) and open item #24 (v1 quantifies only BSJs
// CIRIquant detects natively).
//
// Emits a normalised BSJ BED (for the consensus step) alongside the raw GTF
// (for CIRCRNA_QUANT_MATRIX).

process CIRIQUANT {
    tag "${meta.id}"
    label 'process_high'
    container 'quay.io/biocontainers/ciriquant:1.1.2--pyhdfd78af_2'   // TODO: pin via shared container policy

    publishDir "${params.outdir}/circrnaseq/calls/ciriquant", mode: 'copy'

    input:
    tuple val(meta), path(reads)
    path ciriquant_ref

    output:
    tuple val(meta), path("${meta.id}/${meta.id}.gtf"),      emit: gtf
    tuple val(meta), path("${meta.id}.ciriquant.bsj.bed"),   emit: bsj
    tuple val(meta), path("${meta.id}/${meta.id}.log"),      emit: log

    script:
    def r1 = reads instanceof List ? reads[0] : reads
    def r2 = (reads instanceof List && reads.size() == 2) ? reads[1] : ''
    def bsj_min = params.circrna_bsj_min_reads ?: 2
    """
    CIRIquant \\
        -t ${task.cpus} \\
        -1 ${r1} ${r2 ? "-2 ${r2}" : ''} \\
        --config ${ciriquant_ref}/config.yaml \\
        -o ${meta.id} \\
        -p ${meta.id}

    # normalise: BSJ BED from the CIRIquant GTF (bsj_reads attribute), pre-filter
    # to the minimum read support so the consensus merge starts from clean input
    awk -v m=${bsj_min} 'BEGIN{OFS="\\t"} \$3=="circRNA" {
        match(\$0, /bsj ([0-9.]+)/, b);
        if (b[1]+0 >= m) print \$1, \$4-1, \$5, \$1":"\$4"-"\$5, b[1], \$7
    }' ${meta.id}/${meta.id}.gtf > ${meta.id}.ciriquant.bsj.bed
    """

    stub:
    """
    mkdir -p ${meta.id}
    touch ${meta.id}/${meta.id}.gtf ${meta.id}/${meta.id}.log
    printf 'chr1\\t999\\t2000\\tchr1:1000-2000\\t7\\t+\\n' > ${meta.id}.ciriquant.bsj.bed
    """
}
