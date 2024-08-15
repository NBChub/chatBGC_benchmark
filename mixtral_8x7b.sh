#!/bin/bash

# Define variables
DIR="result/mixtral_8x7b"
DATABASE="data/antismash_db.duckdb"
QUESTION="test/question_sql_pair.json"
LLM_TYPE="ollama"
MODEL="mixtral:8x7b"

# Run the benchmark script
bash benchmark.sh $DIR $DATABASE $QUESTION $LLM_TYPE $MODEL
