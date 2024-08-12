#!/bin/bash

# Define variables
DIR="result/llama3.1_70b"
DATABASE="data/G1032_20240208__dbt_bgcflow.duckdb"
QUESTION="test/question_sql_pair.json"
LLM_TYPE="ollama"
MODEL="llama3.1:70b"

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
if [ -d "$DIR" ]; then
    echo "Directory $DIR already exists. Skipping creation and training."
else
    # Create the directory and run the training command
    mkdir -p "$DIR"
    (cd "$DIR" && chatbgc train --llm_type $LLM_TYPE --model ../../../$MODEL ../../../$DATABASE)
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
        echo "File $FILE exists. Removing it."
        rm "$FILE"
    else
        echo "File $FILE does not exist. Skipping removal."
    fi
    echo "Running benchmark iteration $i"
    (cd $DIR && python ../../../scripts/test.py ../../../$DATABASE ../../../$QUESTION \
        --llm_type $LLM_TYPE \
        --model $MODEL \
        --output_dir "benchmark_$current_branch/iteration_$i" &>> "benchmark_$current_branch/iteration_$i/benchmark.log")
done

echo "Benchmark completed."
