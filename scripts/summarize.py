import argparse
import logging
from pathlib import Path

import pandas as pd

# Set up logging
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)


def main(models, llm_type, chatbgc_version, benchmark_version):
    results = {}
    for m in models:
        result_folder = Path(
            f"result/openai_chat__{m}/chatbgc_{chatbgc_version}/benchmark_{benchmark_version}/"
        )
        for iteration in result_folder.glob(
            f"iteration_*/llm_response_{llm_type}__{m}/*.json"
        ):
            response_id = f"{iteration.stem}__{iteration.parent.parent.name}"
            result = pd.read_json(iteration, typ="series").to_dict()
            result["model"] = m
            result["llm_type"] = llm_type
            result["chatbgc_version"] = chatbgc_version
            result["benchmark_version"] = benchmark_version
            results[response_id] = result

    df = pd.DataFrame.from_dict(results).T
    output_file = f"result/benchmark_result_{chatbgc_version}_{benchmark_version}.csv"
    df.to_csv(output_file)
    logger.info(f"Results saved to {output_file}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Summarize benchmark results.")
    parser.add_argument(
        "--models",
        nargs="+",
        default=["gpt-4o", "gpt-4o-mini"],
        help="List of models to process",
    )
    parser.add_argument("--llm_type", default="openai_chat", help="Type of LLM")
    parser.add_argument("--chatbgc_version", default="0.2.0", help="Version of chatbgc")
    parser.add_argument(
        "--benchmark_version", default="bde51dc", help="Version of benchmark"
    )

    args = parser.parse_args()

    logger.info(
        f"Starting summarization with models: {args.models}, llm_type: {args.llm_type}, chatbgc_version: {args.chatbgc_version}, benchmark_version: {args.benchmark_version}"
    )
    main(args.models, args.llm_type, args.chatbgc_version, args.benchmark_version)
