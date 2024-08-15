#!/bin/bash

# Define variables
DIR="result/gpt-4o"
DATABASE="data/antismash_db.duckdb"
QUESTION="test/question_sql_pair.json"
LLM_TYPE="openai_chat"
MODEL="gpt-4o"

# Run the benchmark script
bash benchmark.sh $DIR $DATABASE $QUESTION $LLM_TYPE $MODEL
