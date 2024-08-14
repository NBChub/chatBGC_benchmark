#!/bin/bash

# Define variables
DIR="result/openai_chat__gpt-4o-mini"
DATABASE="data/G1032_20240208__dbt_bgcflow.duckdb"
QUESTION="test/question_sql_pair.json"
LLM_TYPE="openai_chat"
MODEL="gpt-4o-mini"

# Run the benchmark script
bash benchmark.sh $DIR $DATABASE $QUESTION $LLM_TYPE $MODEL
