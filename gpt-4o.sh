#!/bin/bash

# Define variables
DIR="result/openai_chat__gpt-4o"
DATABASE="../../data/G1032_20240208__dbt_bgcflow.duckdb"
QUESTION="../../test/question_sql_pair.json"
LLM_TYPE="openai_chat"
MODEL="gpt-4o"

# Check if the directory exists
if [ -d "$DIR" ]; then
    echo "Directory $DIR already exists. Skipping creation and training."
else
    # Create the directory and run the training command
    mkdir -p "$DIR"
    (cd "$DIR" && chatbgc train --llm_type $LLM_TYPE --model $MODEL $DATABASE)
    echo "Directory $DIR created and training completed."
fi

# Run the benchmark command three times
for i in {1..3}; do
# Overwrite the benchmark log file
    mkdir -p "$DIR/iteration_$i"
    FILE="$DIR/iteration_$i/benchmark.log"
    if [ -f "$FILE" ]; then
        echo "File $FILE exists. Removing it."
        rm "$FILE"
    else
        echo "File $FILE does not exist. Skipping removal."
    fi
    echo "Running benchmark iteration $i"
    (cd $DIR && python ../../scripts/test.py $DATABASE $QUESTION \
        --llm_type $LLM_TYPE \
        --model $MODEL \
        --output_dir "iteration_$i" &>> "iteration_$i/benchmark.log")
done

echo "Benchmark completed."
