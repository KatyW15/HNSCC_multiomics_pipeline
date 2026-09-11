// FIND_CIRC — Bowtie2-arm BSJ detection, run as find_circ's canonical
// single-pass workflow: full Bowtie2 alignment -> unmapped reads ->
// unmapped2anchors.py -> Bowtie2 re-alignment of anchors -> find_circ.py ->
// the packaged BSJ filters. Emits a normalised BSJ BED
// (chr, start, end, name, bsj_reads, strand).
//
// Needs Bowtie2 + samtools + find_circ together, so this uses a mulled
// container — pipeline_architecture.md open item #22 (verify the mulled image
// carries cmp_bed.py / maxlength.py / merge_bed.py; do NOT vendor those GPL
// scripts into bin/).

process FIND_CIRC {
    tag "${meta.id}"
    label 'process_high'
    container 'PLACEHOLDER/mulled-find_circ-bowtie2-samtools'   // TODO open item #22: request via `nf-core modules` mulled tooling and pin

    publishDir "${params.outdir}/circrnaseq/calls/find_circ", mode: 'copy'

    input:
    tuple val(meta), path(reads)
    path index
    path fasta

    output:
    tuple val(meta), path("${meta.id}.find_circ.bsj.bed"), emit: bsj
    tuple val(meta), path("${meta.id}.sites.bed"),         emit: raw
    tuple val(meta), path("${meta.id}.find_circ.log"),     emit: log

    script:
    def idx_base = "${index}/${fasta.baseName}"
    def r1 = reads instanceof List ? reads[0] : reads
    def r2 = (reads instanceof List && reads.size() == 2) ? reads[1] : ''
    def input_args = r2 ? "-1 ${r1} -2 ${r2}" : "-U ${r1}"
    def bsj_min = params.circrna_bsj_min_reads ?: 2
    """
    # 1. full alignment; keep the unmapped reads
    bowtie2 -p ${task.cpus} --very-sensitive --mm --score-min=C,-15,0 \\
        -x ${idx_base} ${input_args} 2> ${meta.id}.bowtie2_1.log \\
        | samtools view -hbuS - | samtools sort -@ ${task.cpus} - -o ${meta.id}.bowtie2.bam
    samtools view -hf 4 ${meta.id}.bowtie2.bam | samtools view -Sb - > ${meta.id}.unmapped.bam

    # 2. split unmapped reads into anchors and re-align
    unmapped2anchors.py ${meta.id}.unmapped.bam | gzip > ${meta.id}.anchors.fq.gz
    bowtie2 -p ${task.cpus} --reorder --mm --score-min=C,-15,0 -q \\
        -x ${idx_base} -U ${meta.id}.anchors.fq.gz 2> ${meta.id}.bowtie2_2.log \\
        | find_circ.py \\
            --genome=${fasta} \\
            --prefix=${meta.id}_ \\
            --name=${meta.id} \\
            --stats=${meta.id}.find_circ.log \\
            --reads=${meta.id}.spliced_reads.fa \\
        > ${meta.id}.sites.bed 2> ${meta.id}.sites.log

    # 3. packaged filters: keep circRNAs (not linear), min anchor overlap, min reads
    grep CIRCULAR ${meta.id}.sites.bed \\
        | grep -v chrM \\
        | awk -v m=${bsj_min} '\$5 >= m' \\
        | grep UNAMBIGUOUS_BP | grep ANCHOR_UNIQUE \\
        | maxlength.py 100000 \\
        > ${meta.id}.sites.filtered.bed || true

    # 4. normalise to the common BSJ BED shape
    awk 'BEGIN{OFS="\\t"} !/^#/ {print \$1, \$2, \$3, \$1":"\$2"-"\$3, \$5, \$6}' \\
        ${meta.id}.sites.filtered.bed > ${meta.id}.find_circ.bsj.bed
    """

    stub:
    """
    touch ${meta.id}.sites.bed ${meta.id}.find_circ.log
    printf 'chr1\\t1000\\t2000\\tchr1:1000-2000\\t4\\t+\\n' > ${meta.id}.find_circ.bsj.bed
    """
}
