#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { HNSCC_MULTIOMICS } from './workflows/hnscc_multiomics'

workflow {
    HNSCC_MULTIOMICS()
}
