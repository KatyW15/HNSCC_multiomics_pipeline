// MIRNA_TARGET_PREDICT — sequence-level circRNA miRNA-response-element (MRE)
// prediction, feeding INTEGRATION_CERNA. See pipeline_architecture.md §3 and
// bin/mirna_target_predict.R.
//
// Reconstruct circRNA mature sequence from BSJ + exon structure (GENCODE v50),
// then predict MREs for the detected miRNA set (miRanda / RNAhybrid). Output is
// a predicted circRNA–miRNA pair table; expression anti-correlation filtering
// happens in INTEGRATION_CERNA.
//
// TODO: tool choice (miRanda vs RNAhybrid vs both) is an open item — see
// pipeline_architecture.md §6. Real logic lives in bin/mirna_target_predict.R.

process MIRNA_TARGET_PREDICT {
    label 'process_medium'
    container 'PLACEHOLDER/mirna-target-prediction'   // miRanda / RNAhybrid + Biostrings

    publishDir "${params.outdir}/integration/cerna_network", mode: 'copy'

    input:
    path mae
    path circrna_calls, stageAs: 'circrna_calls/*'
    path gtf
    path fasta

    output:
    path 'circrna_mirna_pairs.tsv', emit: pairs
    path 'circrna_sequences.fa',    emit: sequences

    script:
    """
    # TODO: not implemented — see bin/mirna_target_predict.R
    mirna_target_predict.R \\
        --mae ${mae} \\
        --circrna-calls-dir circrna_calls \\
        --gtf ${gtf} \\
        --fasta ${fasta} \\
        --out-pairs circrna_mirna_pairs.tsv \\
        --out-sequences circrna_sequences.fa
    """

    stub:
    """
    touch circrna_mirna_pairs.tsv circrna_sequences.fa
    """
}
