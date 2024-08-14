#!/bin/bash

# Define variables
REPO_DIR=$PWD
DIR=$PWD/$1
DATABASE=$2
QUESTION=$3
LLM_TYPE=$4
MODEL=$5
TRAINING_FOLDER="--training_folder $REPO_DIR/train/antismash"


# get chatbgc version
CHATBGC_VERSION=$(chatbgc version)
echo "ChatBGC version: $CHATBGC_VERSION"

# Get the current branch name
current_branch=$(git rev-parse --abbrev-ref HEAD)
if [ "$current_branch" == "HEAD" ]; then
    current_branch=$(git describe --tags)
fi
echo "Current branch: $current_branch"

# Get the latest commit hash
commit_hash=$(git rev-parse HEAD)
short_commit_hash=$(echo $commit_hash | cut -c 1-7)

# Check if the current branch is main
if [ "$current_branch" == "main" ]; then
    echo "Short commit hash: $short_commit_hash"
    current_branch="$current_branch_$short_commit_hash"
fi

# Check if the directory exists
DIR="$DIR/chatbgc_$CHATBGC_VERSION"
if [ -f "$DIR/chroma.sqlite3" ]; then
    echo "Vector database already exists in $DIR/chroma.sqlite3. Skipping creation and training."
else
    # Create the directory and run the training command
    mkdir -p "$DIR"
    echo "Training RAG. Additional parameters: $TRAINING_FOLDER"
    (cd "$DIR" && chatbgc train --llm_type $LLM_TYPE --model $MODEL $REPO_DIR/$DATABASE $TRAINING_FOLDER &>> training.log) || { rm -f "$DIR/chroma.sqlite3"; echo "Warning: Training failed. Removed $DIR/chroma.sqlite3"; exit 1; }
    echo "Directory $DIR created and training completed."
fi

# Run the benchmark command three times
BENCHMARK_DIR="$DIR/benchmark_$current_branch"
mkdir -p "$BENCHMARK_DIR"
for i in {1..3}; do
# Overwrite the benchmark log file
    mkdir -p "$BENCHMARK_DIR/iteration_$i"
    FILE="$BENCHMARK_DIR/iteration_$i/benchmark.log"
    if [ -f "$FILE" ]; then
        echo "File $FILE exists. Removing previous log file."
        rm "$FILE"
    fi
    echo "Running benchmark iteration $i"
    (cd $DIR && python $REPO_DIR/scripts/test.py $REPO_DIR/$DATABASE $REPO_DIR/$QUESTION \
        --llm_type $LLM_TYPE \
        --model $MODEL \
        --output_dir "benchmark_$current_branch/iteration_$i" &>> "benchmark_$current_branch/iteration_$i/benchmark.log")
done

echo "Benchmark completed."
