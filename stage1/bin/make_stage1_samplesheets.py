#!/usr/bin/env python3
"""Split the HNSCC master samplesheet into the three Stage 1 nf-core samplesheets.

    wgs      rows -> sarek_samplesheet.csv     (nf-core/sarek)
    rnaseq   rows -> rnaseq_samplesheet.csv    (nf-core/rnaseq)
    smrnaseq rows -> smrnaseq_samplesheet.csv  (nf-core/smrnaseq)

circrnaseq rows are ignored here (they belong to Stage 2).

Example:
    python3 make_stage1_samplesheets.py \\
        --master master_samplesheet.csv \\
        --sex-lookup stage1_sarek_samplesheet_with_sex.csv \\
        --patients TP00471 \\
        --outdir samplesheets/test
"""

import argparse
import csv
import os
import re
import sys
from collections import defaultdict

REQUIRED_COLUMNS = ["patient_id", "batch_id", "tissue", "modality",
                    "sample_id", "fastq_1", "fastq_2"]
TISSUE_TO_SAREK_STATUS = {"normal": "0", "tumor": "1"}
VALID_SEX = {"XX", "XY", "NA"}
MISSING_VALUES = {"", "NA"}

# Output file name and column order for each Stage 1 pipeline.
OUTPUTS = {
    "wgs":      ("sarek_samplesheet.csv",
                 ["patient", "sex", "status", "sample", "lane", "fastq_1", "fastq_2"]),
    "rnaseq":   ("rnaseq_samplesheet.csv",
                 ["sample", "fastq_1", "fastq_2", "strandedness"]),
    # nf-core/smrnaseq is single-end: R1 only. Small-RNA inserts (~22 nt) are much
    # shorter than the read, so R1 already holds the whole molecule.
    "smrnaseq": ("smrnaseq_samplesheet.csv",
                 ["sample", "fastq_1"]),
}


def parse_args():
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--master", required=True, help="master samplesheet CSV")
    parser.add_argument("--outdir", required=True, help="directory to write the sheets into")
    parser.add_argument("--batch", nargs="+", help="only keep these batch_id values")
    parser.add_argument("--patients", nargs="+", help="only keep these patient_id values (for tests)")
    parser.add_argument("--sex-lookup",
                        help="CSV with 'patient' and 'sex' columns, used when the master "
                             "sheet has no sex column (e.g. stage1_sarek_samplesheet_with_sex.csv)")
    parser.add_argument("--strandedness", default="auto",
                        help="nf-core/rnaseq strandedness for every sample (default: auto)")
    parser.add_argument("--check-files", action="store_true",
                        help="fail if any fastq path does not exist (run this on Alpine)")
    return parser.parse_args()


def read_csv(path):
    """Return the rows of a CSV as a list of dicts keyed by the header."""
    with open(path, newline="") as handle:
        return list(csv.DictReader(handle))


def load_sex_lookup(path):
    """Map patient -> sex from a CSV that has 'patient' and 'sex' columns."""
    lookup = {}
    for row in read_csv(path):
        lookup[row["patient"]] = row["sex"]
    return lookup


def lane_from_fastq(path):
    """Pull the Illumina lane (e.g. 'L002') out of a fastq name; default to L001."""
    match = re.search(r"_(L\d{3})_", os.path.basename(path))
    return match.group(1) if match else "L001"


def main():
    args = parse_args()
    rows = read_csv(args.master)
    errors = []
    warnings = []

    missing_cols = [c for c in REQUIRED_COLUMNS if c not in rows[0]]
    if missing_cols:
        sys.exit("ERROR: master sheet is missing columns: " + ", ".join(missing_cols))

    sex_lookup = load_sex_lookup(args.sex_lookup) if args.sex_lookup else {}

    # 1. Keep only the rows we want: Stage 1 modalities, chosen batches/patients,
    #    and rows that actually have fastq files.
    kept = []
    for row in rows:
        if row["modality"] not in OUTPUTS:
            continue
        if args.batch and row["batch_id"] not in args.batch:
            continue
        if args.patients and row["patient_id"] not in args.patients:
            continue
        if row["fastq_1"].strip() in MISSING_VALUES:
            warnings.append("skipping %s: no fastq (%s)" % (row["sample_id"], row.get("notes", "")))
            continue
        kept.append(row)

    if args.patients:
        found = {row["patient_id"] for row in kept}
        for patient in args.patients:
            if patient not in found:
                errors.append("patient %s has no Stage 1 rows after filtering" % patient)

    # 2. Check the rows we kept.
    seen_samples = set()
    for row in kept:
        sample = row["sample_id"]
        if sample in seen_samples:
            errors.append("duplicate sample_id %s" % sample)
        seen_samples.add(sample)
        if row["tissue"] not in TISSUE_TO_SAREK_STATUS:
            errors.append("%s: tissue must be tumor or normal, got '%s'" % (sample, row["tissue"]))
        if args.check_files:
            for col in ("fastq_1", "fastq_2"):
                path = row[col]
                if path not in MISSING_VALUES and not os.path.exists(path):
                    errors.append("%s: %s not found: %s" % (sample, col, path))

    # 3. Build the output rows for each pipeline.
    out_rows = {modality: [] for modality in OUTPUTS}
    patients = defaultdict(set)      # modality -> patients in that sheet
    wgs_tissues = defaultdict(set)   # patient -> {"tumor", "normal"} seen in WGS

    for row in kept:
        modality = row["modality"]
        patients[modality].add(row["patient_id"])
        if modality == "wgs":
            patient = row["patient_id"]
            sex = row.get("sex") or sex_lookup.get(patient, "")
            if sex not in VALID_SEX:
                errors.append("%s: sex must be XX, XY or NA, got '%s' "
                              "(ASCAT/Control-FREEC need it)" % (row["sample_id"], sex))
            wgs_tissues[patient].add(row["tissue"])
            out_rows["wgs"].append({
                "patient": patient,
                "sex": sex,
                "status": TISSUE_TO_SAREK_STATUS.get(row["tissue"], ""),
                "sample": row["sample_id"],
                "lane": lane_from_fastq(row["fastq_1"]),
                "fastq_1": row["fastq_1"],
                "fastq_2": row["fastq_2"],
            })
        elif modality == "rnaseq":
            out_rows["rnaseq"].append({
                "sample": row["sample_id"],
                "fastq_1": row["fastq_1"],
                "fastq_2": row["fastq_2"],
                "strandedness": args.strandedness,
            })
        elif modality == "smrnaseq":
            out_rows["smrnaseq"].append({
                "sample": row["sample_id"],
                "fastq_1": row["fastq_1"],
            })

    for patient, tissues in sorted(wgs_tissues.items()):
        if "normal" not in tissues:
            warnings.append("WGS patient %s has no normal: sarek will run it tumor-only" % patient)

    for message in warnings:
        print("WARNING: " + message, file=sys.stderr)
    if errors:
        for message in errors:
            print("ERROR: " + message, file=sys.stderr)
        sys.exit("%d error(s); no samplesheets written" % len(errors))

    # 4. Write one CSV per pipeline. A pipeline with no rows gets no file, so the
    #    launcher can tell it should be skipped; an old file from a previous run
    #    in the same outdir is removed so it can't be picked up by mistake.
    os.makedirs(args.outdir, exist_ok=True)
    for modality, (filename, columns) in OUTPUTS.items():
        path = os.path.join(args.outdir, filename)
        if not out_rows[modality]:
            if os.path.exists(path):
                os.remove(path)
            print("%-25s skipped (no %s rows)" % (filename, modality))
            continue
        with open(path, "w", newline="") as handle:
            writer = csv.DictWriter(handle, fieldnames=columns, lineterminator="\n")
            writer.writeheader()
            writer.writerows(out_rows[modality])
        print("%-25s %3d samples, %2d patients"
              % (filename, len(out_rows[modality]), len(patients[modality])))


if __name__ == "__main__":
    main()
