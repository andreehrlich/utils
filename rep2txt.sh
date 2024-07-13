#!/bin/bash

# Check if the directory path is provided as an argument
if [ $# -eq 0 ]; then
  echo "Please provide the directory path as an argument."
  exit 1
fi

# Directory path
directory="$1"

# Output file name
output_file="$1-concatenated.txt"

# Subdirectories to ignore (space-separated list)
ignore_dirs=("data" "man")

# File extensions to include (space-separated list)
include_extensions=("txt" "md" "log" "R" "stan" "Rd" "RDS" "rda")

# Specific file names to include (space-separated list)
include_files=("README" "LICENSE")

# Recursive function to process files
process_files() {
  for file in "$1"/*; do
    echo "$file"
    if [ -d "$file" ]; then
      # Check if the directory should be ignored
      if [[ ! " ${ignore_dirs[@]} " =~ " $(basename "$file") " ]]; then
        # If the item is a directory, recursively process its contents
        process_files "$file"
      fi
    elif [ -f "$file" ] && [ "$(basename "$file")" != "$output_file" ]; then
      # Check if the file has an allowed extension or specific name
      if [[ " ${include_extensions[@]} " =~ " $(echo "${file##*.}" | tr '[:upper:]' '[:lower:]') " || " ${include_files[@]} " =~ " $(basename "$file") " ]]; then
        # If the file has an allowed extension or specific name, append its contents to the output file
        echo "------------------------" >> "$output_file"
        echo "File: $file" >> "$output_file"
        echo "------------------------" >> "$output_file"
        cat "$file" >> "$output_file"
        echo "" >> "$output_file"  # Add a newline between files
      fi
    fi
  done
}

# Initialize the output file
echo "" > "$output_file"

# Start processing files recursively
process_files "$directory"

echo "Concatenation complete. Output file: $output_file"
