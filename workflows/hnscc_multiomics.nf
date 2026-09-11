// Top-level orchestrator — see pipeline_architecture.md §2 for the full
// design (per-modality channel branching, missing-modality tolerance,
// map-based joins in INTEGRATION rather than strict Nextflow channel joins).
//
// Not yet implemented: each commented `include` below is a placeholder for a
// subworkflow that still needs to be built. See pipeline_architecture.md §3
// (implementation order: INPUT_CHECK -> RNASEQ_ADAPTER/WGS_ADAPTER ->
// CIRCRNASEQ -> HPV_DETECTION -> SMRNASEQ -> INTEGRATION).
//
// Built out so far: INPUT_CHECK (full), CIRCRNASEQ (structure + module/bin
// scaffolds — the bespoke bin/circrna_*.R|py steps still `stop()`; runnable
// end to end only with `-stub-run`). Its `chimeric_junctions` input comes from
// RNASEQ_ADAPTER, which is still stubbed — an empty channel is passed until
// that arm is wired (CIRCRNA_COVALIDATE tolerates it, writing NA).

include { INPUT_CHECK } from '../subworkflows/local/input_check'
// include { WGS_ADAPTER     } from '../subworkflows/local/1_WGS'
// include { RNASEQ_ADAPTER  } from '../subworkflows/local/2_totalRNAseq'
include { CIRCRNASEQ         } from '../subworkflows/local/3_circRNAseq'
// include { SMRNASEQ        } from '../subworkflows/local/4_smRNAseq'
// include { HPV_DETECTION   } from '../subworkflows/local/hpv_detection'
// include { INTEGRATION     } from '../subworkflows/local/integration'
// include { REPORTING       } from '../subworkflows/local/reporting'

workflow HNSCC_MULTIOMICS {

    main:
    if (!params.samplesheet) {
        error "Missing required parameter --samplesheet (see docs/usage.md)"
    }

    log.warn "HNSCC_MULTIOMICS: INPUT_CHECK + CIRCRNASEQ wired in; other downstream subworkflows still stubbed."

    INPUT_CHECK(params.samplesheet)

    // RNASEQ_ADAPTER(INPUT_CHECK.out.rnaseq, params.rnaseq_results)
    // WGS_ADAPTER(INPUT_CHECK.out.wgs, params.sarek_results)

    // circRNA arm — chimeric junctions come from RNASEQ_ADAPTER once it exists;
    // empty channel until then (CIRCRNA_COVALIDATE handles the absence).
    ch_chimeric_junctions = Channel.empty()   // TODO: RNASEQ_ADAPTER.out.chimeric_junctions
    CIRCRNASEQ(INPUT_CHECK.out.circrnaseq, ch_chimeric_junctions)

    // TODO:
    // HPV_DETECTION(RNASEQ_ADAPTER.out.unmapped, CIRCRNASEQ.out.unmapped, WGS_ADAPTER.out.unmapped)
    // SMRNASEQ(INPUT_CHECK.out.smrnaseq)
    // INTEGRATION(CIRCRNASEQ.out, RNASEQ_ADAPTER.out, SMRNASEQ.out, WGS_ADAPTER.out, HPV_DETECTION.out)
    //   emits: mae, recurrence_scores, cerna_network, genomic_correlation,
    //          hpv_axis, structure, biomarker_candidates, candidate_registry
    // REPORTING(INTEGRATION.out)
}
