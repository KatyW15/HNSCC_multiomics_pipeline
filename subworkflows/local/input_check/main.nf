// INPUT_CHECK — see pipeline_architecture.md §3
//
// Reads the master sample sheet, validates each row against the controlled
// vocabulary documented in docs/usage.md, checks fastq path existence for
// rows that actually carry data, and branches into one channel per modality.
// A row whose fastq_1 is blank or NA is a documented missing modality (see
// docs/usage.md), not an error — it's excluded from its modality channel
// below but still recorded in the completeness report so the gap is visible
// before compute starts, per the architecture doc's "missing data is normal,
// not an error" principle. Its sample_id may be kept (the master sheet does).

import groovy.transform.Field

@Field def VALID_TISSUE       = ['tumor', 'normal']
@Field def VALID_MODALITY     = ['rnaseq', 'circrnaseq', 'smrnaseq', 'wgs']
@Field def VALID_HPV_STATUS   = ['positive', 'negative', 'unknown']
@Field def VALID_HPV_GENOTYPE = ['HPV16', 'HPV18', 'other_highrisk', 'NA']

// Blank and 'NA' both mean "no value" (the master sheet uses NA).
def has_value(value) {
    def v = value?.trim()
    return v && v != 'NA'
}

def validate_row(row) {
    def where = "patient_id=${row.patient_id}, tissue=${row.tissue}, modality=${row.modality}, sample_id=${row.sample_id ?: '(blank)'}"

    if (!row.patient_id) {
        error "INPUT_CHECK: samplesheet row is missing patient_id (${where})"
    }
    if (!(row.tissue in VALID_TISSUE)) {
        error "INPUT_CHECK: invalid tissue '${row.tissue}' — must be one of ${VALID_TISSUE} (${where})"
    }
    if (!(row.modality in VALID_MODALITY)) {
        error "INPUT_CHECK: invalid modality '${row.modality}' — must be one of ${VALID_MODALITY} (${where})"
    }
    if (!(row.hpv_status in VALID_HPV_STATUS)) {
        error "INPUT_CHECK: invalid hpv_status '${row.hpv_status}' — must be one of ${VALID_HPV_STATUS} (${where})"
    }
    // hpv_genotype is an optional column (not present in every samplesheet
    // this pipeline has been handed) — only validated when supplied.
    if (row.hpv_genotype && !(row.hpv_genotype in VALID_HPV_GENOTYPE)) {
        error "INPUT_CHECK: invalid hpv_genotype '${row.hpv_genotype}' — must be one of ${VALID_HPV_GENOTYPE} (${where})"
    }

    // A present row (fastq_1 set) must carry a sample_id; a missing row
    // (fastq_1 blank/NA) must not have a stray fastq_2.
    def has_fastq1 = has_value(row.fastq_1)
    def has_fastq2 = has_value(row.fastq_2)
    if (has_fastq1 && !has_value(row.sample_id)) {
        error "INPUT_CHECK: fastq_1 set but sample_id is blank (${where})"
    }
    if (!has_fastq1 && has_fastq2) {
        error "INPUT_CHECK: fastq_2 set but fastq_1 is blank (${where})"
    }
    if (has_fastq1 && !file(row.fastq_1).exists()) {
        error "INPUT_CHECK: fastq_1 does not exist: ${row.fastq_1} (${where})"
    }
    if (has_fastq2 && !file(row.fastq_2).exists()) {
        error "INPUT_CHECK: fastq_2 does not exist: ${row.fastq_2} (${where})"
    }

    return row
}

def to_meta_tuple(row) {
    def meta = [
        id          : row.sample_id,
        patient_id  : row.patient_id,
        batch_id    : row.batch_id,
        tissue      : row.tissue,
        modality    : row.modality,
        hpv_status  : row.hpv_status,
        hpv_genotype: row.hpv_genotype ?: 'NA',
        single_end  : !has_value(row.fastq_2),
    ]
    def fastq_1 = file(row.fastq_1)
    def fastq_2 = has_value(row.fastq_2) ? file(row.fastq_2) : null
    return tuple(meta, fastq_1, fastq_2)
}

workflow INPUT_CHECK {
    take:
    samplesheet

    main:
    rows = Channel
        .fromPath(samplesheet, checkIfExists: true)
        .splitCsv(header: true)
        .map { row -> validate_row(row) }

    // Per-patient/tissue/modality completeness — a run artifact so gaps are
    // visible before compute starts rather than discovered mid-run.
    rows
        .map { row -> [row.patient_id, row.tissue, row.modality, has_value(row.fastq_1) ? 'present' : 'missing'].join('\t') }
        .collectFile(
            name: 'patient_completeness.tsv',
            storeDir: "${params.outdir}/pipeline_info",
            newLine: true,
            seed: ['patient_id', 'tissue', 'modality', 'status'].join('\t')
        )

    present = rows.filter { row -> has_value(row.fastq_1) }

    branched = present
        .map { row -> to_meta_tuple(row) }
        .branch {
            rnaseq_ch:     it[0].modality == 'rnaseq'
            circrnaseq_ch: it[0].modality == 'circrnaseq'
            smrnaseq_ch:   it[0].modality == 'smrnaseq'
            wgs_ch:        it[0].modality == 'wgs'
        }

    emit:
    rnaseq     = branched.rnaseq_ch
    circrnaseq = branched.circrnaseq_ch
    smrnaseq   = branched.smrnaseq_ch
    wgs        = branched.wgs_ch
}
