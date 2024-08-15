#!/bin/bash

# Define variables
DIR="result/gpt-3.5-turbo"
DATABASE="data/antismash_db.duckdb"
QUESTION="test/question_sql_pair.json"
LLM_TYPE="openai_chat"
MODEL="gpt-3.5-turbo"

# Run the benchmark script
bash benchmark.sh $DIR $DATABASE $QUESTION $LLM_TYPE $MODEL
