#!/bin/bash

# Define variables
DIR="result/gemma2_27b"
DATABASE="data/antismash_db.duckdb"
QUESTION="test/question_sql_pair.json"
LLM_TYPE="ollama"
MODEL="gemma2:27b"

# Run the benchmark script
bash benchmark.sh $DIR $DATABASE $QUESTION $LLM_TYPE $MODEL
