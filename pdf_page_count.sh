#!/bin/bash

# Check if pdfinfo is installed
if ! command -v pdfinfo &> /dev/null
then
    echo "Error: pdfinfo is not installed. Please install poppler-utils package."
    exit 1
fi

# Check if directory path is provided as an argument
if [ $# -eq 0 ]; then
    echo "Error: Please provide the directory path as an argument."
    exit 1
fi

# Set the directory path from the argument
dir_path="$1"

# Check if the directory exists
if [ ! -d "$dir_path" ]; then
    echo "Error: Directory '$dir_path' does not exist."
    exit 1
fi

# Initialize total page count
total_pages=0

# Print the table header
printf "%-30s %-10s %-20s %s\n" "Filename" "Size (MB)" "Date" "Pages"
printf "%-30s %-10s %-20s %s\n" "--------" "---------" "----" "-----"

# Find all PDF files in the directory and its subdirectories
while IFS= read -r -d '' file; do
    # Get the page count using pdfinfo
    page_count=$(pdfinfo "$file" | awk '/^Pages:/ {print $2}')
    
    # Get the file size in bytes
    size_bytes=$(stat -f%z "$file")
    
    # Convert size to MB with 2 decimal places
    size_mb=$(awk "BEGIN {printf \"%.2f\", $size_bytes/1024/1024}")
    
    # Get the file modification date
    file_date=$(stat -f"%Sm" -t "%Y-%m-%d" "$file")
    
    # Get the filename without the path
    filename=$(basename "$file")
    
    # Truncate the filename to the first 30 characters
    truncated_filename=$(echo "$filename" | cut -c 1-30)
    
    # Print the file details in a table row
    printf "%-30s %-10s %-20s %d\n" "$truncated_filename" "$size_mb" "$file_date" "$page_count"
    
    # Add the page count to the total
    total_pages=$((total_pages + page_count))
done < <(find "$dir_path" -type f -name "*.pdf" -print0)

# Print the total page count
echo "Total pages: $total_pages"
