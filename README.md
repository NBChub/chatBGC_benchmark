# chatBGC_benchmark

This is the repository for Benchmarking ChatBGC with different foundational models using th G1034 dataset from DTU Biosustain.

# Running the Benchmark
## Get access to OpenAI API
To get the OpenAI API key, you can ask @matinnuhamunada for a key or use your own [API](https://platform.openai.com/api-keys).

Then, run this on your terminal
```bash
OPENAI_API_KEY="<change this to your API Key>"
```

## Installing ChatBGC
Assuming you are using one of our shared machines and have python installed, follow this steps:
```bash
# Clone the benchmark repository
git clone git@github.com:NBChub/chatBGC_benchmark.git
cd chatBGC_benchmark

# Copy BGCFlow run result for G1032 dataset (using one the shared machine at the NPGM DTU Biosustain)
mkdir data
cp ~/net/o-drive/CFB-S-NewBioactiveCompounds/11_G1000/bgcflow/G1034_20240208/data/processed/G1032_20240208/dbt/antiSMASH_7.1.0/dbt_bgcflow.duckdb data/G1032_20240208__dbt_bgcflow.duckdb -n

# Create python environment and install ChatBGC
python3 -m venv chatbgc_env
source chatbgc_env/bin/activate
python3 -m pip install --upgrade pip
pip install git+https://github.com/NBChub/chatBGC.git@main #change the version accordingly

# Setup variable environment / secrets
touch .env
echo "export OPENAI_API_KEY=$OPENAI_API_KEY" > .env
source .env
```

## Running ChatBGC Benchmark

1. `GPT-4o`
```bash
bash gpt-4o.sh
```

2. `GPT-4o-mini`
```bash
bash gpt-4o-mini.sh
```

3. `llama3:70b`
```bash
bash llama3_70b.sh
```

# [IMPORTANT UPDATE] - New Database Structure
We have finished the BGCFlow run for the G1034 dataset. Unfortunately, two genomes were dropped because of an issue with the annotation (inconsistent exon ordering for features):
- NBC_01310 (`NBC_0131000000000_213589.current.gb`)
- NBC_01080 (`NBC_0108000000000_76298.current.gb`).

Therefore, currently we only have result ready for the 1032 genomes (`~/net/o-drive/CFB-S-NewBioactiveCompounds/11_G1000/bgcflow/G1034_20240208/data/processed/G1032_20240208`).

The new database structure now host two data schema, one for BGCFlow and another for antiSMASH. In the SQL query, this ca be fetched by explicitly mentioning the schema, for example `bgcflow.cdss` and `antismash.cdss` are two different tables. See at the bottom on how it looks like in DBeaver.

# Manually exploring the database
If you want to explore the database generated manually, the easiest way is to install [DBeaver](https://dbeaver.io/download/)

![Picture1](https://github.com/user-attachments/assets/158d6c4b-d990-431d-a77e-c14f408bf5c9)
![Picture2](https://github.com/user-attachments/assets/a553bfa7-10b5-4b72-a208-61e4e0044710)
![Picture3](https://github.com/user-attachments/assets/7dc78e6e-c721-4d39-a346-b22e78138598)
![Picture4](https://github.com/user-attachments/assets/e7bc65e8-9774-4154-aa07-532821891f27)
![Picture5](https://github.com/user-attachments/assets/06803f82-505c-4625-b1fa-c44fc84d759b)
