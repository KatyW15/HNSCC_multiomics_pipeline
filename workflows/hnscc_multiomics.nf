// Top-level orchestrator — see pipeline_architecture.md §2 for the full
// design (per-modality channel branching, missing-modality tolerance,
// map-based joins in INTEGRATION rather than strict Nextflow channel joins).
//
// Not yet implemented: each `include` below is a placeholder for a
// subworkflow that still needs to be built. See pipeline_architecture.md §3
// (implementation order: INPUT_CHECK -> RNASEQ_ADAPTER/WGS_ADAPTER ->
// CIRCRNASEQ -> HPV_DETECTION -> SMRNASEQ -> INTEGRATION).

// include { INPUT_CHECK     } from '../subworkflows/local/input_check'
// include { RNASEQ_ADAPTER  } from '../subworkflows/local/rnaseq_adapter'
// include { CIRCRNASEQ      } from '../subworkflows/local/circrnaseq'
// include { HPV_DETECTION   } from '../subworkflows/local/hpv_detection'
// include { SMRNASEQ        } from '../subworkflows/local/smrnaseq'
// include { WGS_ADAPTER     } from '../subworkflows/local/wgs_adapter'
// include { INTEGRATION     } from '../subworkflows/local/integration'
// include { REPORTING       } from '../subworkflows/local/reporting'

workflow HNSCC_MULTIOMICS {

    main:
    if (!params.samplesheet) {
        error "Missing required parameter --samplesheet (see docs/usage.md)"
    }

    log.warn "HNSCC_MULTIOMICS: scaffold only — no subworkflows wired in yet."

    // TODO:
    // INPUT_CHECK(params.samplesheet)
    // RNASEQ_ADAPTER(INPUT_CHECK.out.rnaseq, params.rnaseq_results)
    // WGS_ADAPTER(INPUT_CHECK.out.wgs, params.sarek_results)
    // CIRCRNASEQ(INPUT_CHECK.out.circrnaseq, RNASEQ_ADAPTER.out.chimeric_junctions)
    // HPV_DETECTION(RNASEQ_ADAPTER.out.unmapped, CIRCRNASEQ.out.unmapped, WGS_ADAPTER.out.unmapped)
    // SMRNASEQ(INPUT_CHECK.out.smrnaseq)
    // INTEGRATION(CIRCRNASEQ.out, RNASEQ_ADAPTER.out, SMRNASEQ.out, WGS_ADAPTER.out, HPV_DETECTION.out)
    // REPORTING(INTEGRATION.out)
}
