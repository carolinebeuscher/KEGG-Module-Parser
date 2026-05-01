#!/bin/bash

# Usage: bash run_module_parser.sh all_tsv.txt <module_file>

# Define inputs
all_tsv="$1"
module_file="$2"
module_name=$(basename "$module_file" .txt)
final_output="${module_name}_functionality.tsv"

# Make directories
output_dir="outputs"
mkdir -p "$output_dir"
mkdir -p logs

# Loop over each TSV file listed in all_tsv
while IFS= read -r tsv; do
    [[ -z "$tsv" ]] && continue

    # Extract species name from path
    species=$(basename "$tsv" | sed 's/_ko_annotations\.tsv$//')

    echo "Processing: $species"

    # Run module_parser
    result=$(python module_parser.py --tsv_file "$tsv" --module_file "$module_file")

    # Write to a temporary species file
    echo -e "${species}\t${result}" > "${output_dir}/${species}_functionality.tsv"

done < "$all_tsv"

# Merge all species files into final output
echo -e "species\tfunctional\tmissing_kos\tpresent_kos" > "$final_output"
cat ${output_dir}/*_functionality.tsv >> "$final_output"

# Clean up temp files
rm -f ${output_dir}/*_functionality.tsv
rmdir "$output_dir" 2>/dev/null || true

echo "Results written to $final_output"
