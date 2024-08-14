#!/bin/bash

# Define variables
DIR="result/llama3.1_8b"
DATABASE="data/G1032_20240208__dbt_bgcflow.duckdb"
QUESTION="test/question_sql_pair.json"
LLM_TYPE="ollama"
MODEL="llama3.1:8b"

# Run the benchmark script
bash benchmark.sh $DIR $DATABASE $QUESTION $LLM_TYPE $MODEL
