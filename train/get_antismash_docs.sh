#!/bin/bash

COMMIT=6c092bb
TARGET_DIR=antismash
ZIP_FILE="$COMMIT.zip"

# Create the target directory if it doesn't exist
mkdir -p $TARGET_DIR

# Download the ZIP file if it doesn't already exist
wget https://github.com/antismash/documentation/archive/$ZIP_FILE -nc

# Check if the ZIP file exists and unzip it
if [ -f "$ZIP_FILE" ]; then
    unzip -o $ZIP_FILE
else
    echo "ZIP file $ZIP_FILE does not exist."
fi

# Find and copy all .md files to the target directory
find documentation* -type f -name "*.md" -exec cp {} "$TARGET_DIR" \;

echo "All .md files have been copied to $TARGET_DIR"

rm -rf documentation* $ZIP_FILE
