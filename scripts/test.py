import argparse
import json
import logging
import os
from pathlib import Path

import requests
from chatbgc import __version__
from vanna.chromadb import ChromaDB_VectorStore
from vanna.ollama import Ollama
from vanna.openai import OpenAI_Chat

# Configure logging
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)

logging.info(f"Using ChatBGC version: {__version__}")


class MyVannaOllama(ChromaDB_VectorStore, Ollama):
    def __init__(self, config=None):
        ChromaDB_VectorStore.__init__(self, config=config)
        Ollama.__init__(self, config=config)


class MyVannaOpenAI(ChromaDB_VectorStore, OpenAI_Chat):
    def __init__(self, config=None):
        ChromaDB_VectorStore.__init__(self, config=config)
        OpenAI_Chat.__init__(self, config=config)


def start_app(duckdb_path, model="llama3", llm_type="ollama"):
    logging.info(
        f"Starting app with DuckDB path: {duckdb_path}, model: {model}, LLM type: {llm_type}"
    )

    if llm_type not in ["ollama", "openai_chat"]:
        raise ValueError(f"Invalid LLM type: {llm_type}")

    config = {"model": model}

    if llm_type == "openai_chat":
        if model == "llama3":
            model = "gpt-4o"
            config["model"] = model

        openai_api_key = os.environ.get("OPENAI_API_KEY")
        if openai_api_key is None:
            raise ValueError("OPENAI_API_KEY environment variable is not set")
        config["api_key"] = openai_api_key

        logging.info("Fetching available models from OpenAI API")
        response = requests.get(
            "https://api.openai.com/v1/models",
            headers={"Authorization": f"Bearer {os.getenv('OPENAI_API_KEY')}"},
        )

        response.raise_for_status()
        available_models = [model["id"] for model in response.json()["data"]]
        if model not in available_models:
            raise ValueError(f"Invalid model. Expected one of: {available_models}")

        logging.info(f"Using {llm_type} model: {model}")

    if llm_type == "ollama":
        vn = MyVannaOllama(config=config)
    elif llm_type == "openai_chat":
        vn = MyVannaOpenAI(config=config)

    logging.info(f"Connecting to DuckDB at {duckdb_path}")
    vn.connect_to_duckdb(url=duckdb_path)
    return vn


def main():
    parser = argparse.ArgumentParser(
        description="Start the Vanna application and process questions."
    )
    parser.add_argument(
        "duckdb_path", type=str, help="The path to the DuckDB database."
    )
    parser.add_argument(
        "questions", type=str, help="The path to the questions JSON file."
    )
    parser.add_argument(
        "--model",
        type=str,
        default="llama3",
        help="The model to use. Defaults to 'llama3' for 'ollama' and 'gpt-4o' for 'openai_chat'.",
    )
    parser.add_argument(
        "--llm_type",
        type=str,
        default="ollama",
        choices=["ollama", "openai_chat"],
        help="The type of language model to use. Defaults to 'ollama'.",
    )
    parser.add_argument(
        "--output_dir",
        type=str,
        default=".",
        help="The directory to save the output files. Defaults to the current directory.",
    )
    parser.add_argument(
        "--refine_prompt",
        type=str,
        default=None,
        help="Additional prompt to help refine the question.",
    )
    args = parser.parse_args()

    logging.info("Starting the Vanna application")
    vn = start_app(args.duckdb_path, model=args.model, llm_type=args.llm_type)

    logging.info(f"Loading questions from {args.questions}")
    with open(args.questions, "r") as f:
        question_dict = json.load(f)

    model_sanitized = args.model.replace(":", "_")
    output_dir = (
        Path(args.output_dir) / f"llm_response_{args.llm_type}__{model_sanitized}"
    )
    output_dir.mkdir(parents=True, exist_ok=True)
    logging.info(f"Output directory set to {output_dir}")

    for q in question_dict:
        outfile_json = (
            output_dir
            / f"Q_{str(q['id']).zfill(2)}__{args.llm_type}__{model_sanitized}__RAG_benchmark.json"
        )
        outfile_csv = (
            output_dir
            / f"Q_{str(q['id']).zfill(2)}__{args.llm_type}__{model_sanitized}__RAG_benchmark.csv"
        )

        if outfile_csv.exists() and outfile_json.exists():
            logging.info(f"Skipping question {q['id']} as output files already exist")
            continue
        else:
            try:
                logging.info(f"Processing question {q['id']}: {q['question']}")
                logging.debug(f"Adding prompt to question: {args.refine_prompt}")
                answer_sql, answer_df, answer_figure = vn.ask(
                    q["question"] + str(args.refine_prompt),
                    auto_train=False,
                    visualize=False,
                    allow_llm_to_see_data=True,
                )
                if len(answer_df) > 100:
                    answer_df = answer_df.loc[:100, :]
                answer_summary = vn.generate_summary(q["question"], answer_df)
                q["answer_sql_expected"] = q.pop("sql")
                q["answer_summary_expected"] = q.pop("answer")
                q["answer_sql_LLM"] = answer_sql
                q["answer_summary_LLM"] = answer_summary

                logging.info(
                    f"Question {q['id']} processed successfully with {len(answer_df)} rows in the answer dataframe"
                )
                logging.info(f"Saving output to {outfile_csv}")
                answer_df.to_csv(outfile_csv)

                logging.info(f"Saving output to {outfile_json}")
                with open(outfile_json, "w") as f:
                    json.dump(q, f, indent=2)
            except Exception as e:
                logging.error(
                    f"Failed to process question {q['id']}: {q['question']}. Error: {e}"
                )
        logging.info("---DONE---")


if __name__ == "__main__":
    main()
