# Shared environment for every Stage 1 run on Alpine. Sourced by run_*.sh, not run directly.
# Taken from notes/sarek/run_sarek_HNSCC_batch1_persistence1.sh.

module load nextflow/25.10.2

# Root directories. Each run_*.sh builds its launch/work/out dirs under these.
export HNSCC_PROJECTS="/projects/$USER/HNSCC_analysis"
export HNSCC_SCRATCH="/scratch/alpine/$USER/HNSCC_analysis"

export NXF_HOME="/projects/$USER/software/nextflow_config"
# Heap per Nextflow head process. TODO: lower (e.g. -Xmx8G) once all 3 heads run
# together on persistence1 -- 3 x 16G may exceed what a persistence1 session allows.
export _JAVA_OPTIONS="-XX:+PerfDisableSharedMem -Xmx16G"

export TMPDIR="/scratch/alpine/$USER/tmp"
export TEMP="$TMPDIR"
export TMP="$TMPDIR"
export NXF_TEMP="$TMPDIR"

# TODO: nextflow_alpine.config sets a different cache (/scratch/.../singularity/cache).
# Pick one location so images aren't pulled twice.
export SINGULARITY_CACHEDIR="/projects/$USER/container_cache"
export SINGULARITY_TMPDIR="/projects/$USER/container_cache/tmp"
export APPTAINER_CACHEDIR="$SINGULARITY_CACHEDIR"
export APPTAINER_TMPDIR="$SINGULARITY_TMPDIR"
export NXF_SINGULARITY_CACHEDIR="$SINGULARITY_CACHEDIR"

mkdir -p "$TMPDIR" "$SINGULARITY_TMPDIR"
