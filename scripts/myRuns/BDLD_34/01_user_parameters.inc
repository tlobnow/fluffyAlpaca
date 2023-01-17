## Set user parameters for alphafold, common to MSA and prediction jobs
source 00_user_parameters.inc
FILE=$FILE

# Comma-separated list of protein data, passed to alphafold via --fasta_paths
FASTA_PATHS=~/fluffyAlpaca/fasta_files/$FILE.fasta

# Output directory to write the results to, passed via --output
OUTPUT_DIR=~/fluffyAlpaca/feature_files/

# Preset for alphafold, passed via --db_preset
PRESET="full_dbs"

