// CIRCRNA_CONSENSUS — merge the per-tool BSJ call sets for one sample.
// See pipeline_architecture.md §3 `CIRCRNASEQ` and open item #1.
//
// Rules (locked 2026-09-03):
//   - match BSJs across tools with a 5 bp coordinate margin
//     (params.circrna_bsj_merge_slop); exact match for canonical junctions
//   - annotate every BSJ with n_tools (1-3) and which tools called it
//   - GT/AG splice-motif check is an ADVISORY flag, not a filter
//   - minimum BSJ read support params.circrna_bsj_min_reads (default 2)
//   - keep ALL >=1-tool calls here with n_tools recorded; the >=2-tool
//     restriction is applied later, only to the quantified DE matrix
//
// Real logic lives in bin/circrna_consensus.R — scaffold for now.

process CIRCRNA_CONSENSUS {
    tag "${meta.id}"
    label 'process_medium'
    container 'PLACEHOLDER/bioconductor-integration'   // GenomicRanges, Biostrings, data.table

    publishDir "${params.outdir}/circrnaseq/consensus", mode: 'copy'

    input:
    tuple val(meta), path(tool_beds), val(tools)
    path fasta
    path fai

    output:
    tuple val(meta), path("${meta.id}.consensus_bsj.tsv"), emit: bsj

    script:
    def slop      = params.circrna_bsj_merge_slop ?: 5
    def min_reads = params.circrna_bsj_min_reads ?: 2
    // tool_beds and tools are parallel lists (same order) from the groupTuple
    def bed_args  = [[tools].flatten(), [tool_beds].flatten()]
                        .transpose()
                        .collect { t, b -> "${t}=${b}" }
                        .join(' ')
    """
    # TODO: not implemented — see bin/circrna_consensus.R
    circrna_consensus.R \\
        --sample ${meta.id} \\
        --tool-beds ${bed_args} \\
        --fasta ${fasta} \\
        --merge-slop ${slop} \\
        --min-bsj-reads ${min_reads} \\
        --out ${meta.id}.consensus_bsj.tsv
    """

    stub:
    """
    printf 'chrom\\tstart\\tend\\tstrand\\tbsj_reads\\tn_tools\\ttools\\tcanonical_motif\\n' > ${meta.id}.consensus_bsj.tsv
    printf 'chr1\\t1000\\t2000\\t+\\t7\\t3\\tcircexplorer2,ciriquant,find_circ\\ttrue\\n' >> ${meta.id}.consensus_bsj.tsv
    """
}
