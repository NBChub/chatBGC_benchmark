#!/bin/bash

# Define variables
DIR="result/mistral-nemo"
DATABASE="data/G1032_20240208__dbt_bgcflow.duckdb"
QUESTION="test/question_sql_pair.json"
LLM_TYPE="ollama"
MODEL="mistral-nemo:latest"

# Run the benchmark script
bash benchmark.sh $DIR $DATABASE $QUESTION $LLM_TYPE $MODEL
