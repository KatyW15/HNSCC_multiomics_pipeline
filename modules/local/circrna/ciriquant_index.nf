// CIRIQUANT_INDEX — build the CIRIquant reference bundle: its config.yaml plus
// the hisat2 index it needs for linear-transcript quantification (BWA index is
// passed in from BWA_INDEX; StringTie/samtools ship in the CIRIquant image).
// Skipped when params.ciriquant_index is set. See pipeline_architecture.md §3
// `CIRCRNASEQ` and open item #22 (container contents).
//
// The emitted `bundle/` dir is self-contained: config.yaml uses relative paths
// so it stages cleanly into the CIRIQUANT process work dir.

process CIRIQUANT_INDEX {
    label 'process_high'
    container 'quay.io/biocontainers/ciriquant:1.1.2--pyhdfd78af_2'   // TODO: pin via shared container policy

    publishDir "${params.outdir}/circrnaseq/reference", mode: 'copy'

    input:
    path fasta
    path gtf
    path bwa_index

    output:
    path 'ciriquant_ref', emit: bundle

    script:
    """
    mkdir -p ciriquant_ref/hisat2
    hisat2-build -p ${task.cpus} ${fasta} ciriquant_ref/hisat2/${fasta.baseName}

    cp ${fasta} ciriquant_ref/
    cp ${gtf}   ciriquant_ref/
    cp -r ${bwa_index} ciriquant_ref/bwa

    cat > ciriquant_ref/config.yaml <<'YAML'
    name: hg38_gencode_v50
    tools:
      bwa: bwa
      hisat2: hisat2
      stringtie: stringtie
      samtools: samtools
    reference:
      fasta: ${fasta}
      gtf: ${gtf}
      bwa_index: bwa/${fasta.baseName}
      hisat_index: hisat2/${fasta.baseName}
    YAML
    """

    stub:
    """
    mkdir -p ciriquant_ref/hisat2 ciriquant_ref/bwa
    touch ciriquant_ref/config.yaml ciriquant_ref/hisat2/idx.1.ht2 ciriquant_ref/bwa/idx.bwt
    """
}
