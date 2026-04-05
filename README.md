# TL-PPO Edge–Cloud Federated Learning (CADE Artifact)

This repository provides a **reproducible implementation** of a Telemetry-Driven PPO (TL-PPO) framework for adaptive computation 
offloading in edge–cloud federated learning systems.

---

## Artifact Evaluation (CADE)

This repository supports full reproducibility:

- ✔ Dataset reconstruction via merge script
- ✔ Multi-client distributed setup (10 clients)
- ✔ Multi-seed experiments (42–46)
- ✔ Reproduction of Figures (Fig.3–Fig.5)
- ✔ Baseline comparisons (FedAvg, DQN, DDQN, TL-PPO)

---

## Repository Structure

.
├── client/
│   └── client_api.py
├── server/
│   ├── server_experiment_cade.py
│   └── plot_cade_results.py
├── scripts/
│   └── merge_telemetry.py
├── data/
│   ├── telemetry_client1.csv ... telemetry_client10.csv
├── shared/
│   ├── feature_cols.json
│   ├── class_map.json
│   └── scaler.json
├── results/
├── figures/
├── requirements.txt
└── README.md

---

## Setup

git clone https://github.com/YOUR_USERNAME/tl-ppo-edge-cloud-federated-learning.git
cd tl-ppo-edge-cloud-federated-learning

python3 -m venv venv
source venv/bin/activate

pip install -r requirements.txt

---

## Step 1: Merge Dataset

python scripts/merge_telemetry.py   --input_dir data   --output_csv data/telemetry_merged.csv

---

## Step 2: Run Clients

## Client 1 Example

nohup python client/client_api.py   --client_id 1   --csv data/telemetry_client1.csv   --port 8000   --class_map shared/class_map.json   --scaler_path shared/scaler.json

## Client 2 Example 

nohup python client/client_api.py   --client_id 2   --csv data/telemetry_client2.csv   --port 8001   --class_map shared/class_map.json   --scaler_path shared/scaler.json

Repeat for clients 3–10 using ports 8001–8009.

---

## Step 3: Run Experiment

nohup python server/server_experiment_cade.py   --csv data/telemetry_merged.csv   --label_col scenario   --clients "http://127.0.0.1:8000,http://127.0.0.1:8001,http://127.0.0.1:8002,http://127.0.0.1:8003,http://127.0.0.1:8004,http://127.0.0.1:8005,http://127.0.0.1:8006,http://127.0.0.1:8007,http://127.0.0.1:8008,http://127.0.0.1:8009"   --rounds 300   --seeds 42,43,44,45,46   --strategies fedavg,random,greedy,dqn,ddqn,tl_ppo   --outdir results/cade_300r

---

## Step 4: Generate Figures

python server/plot_cade_results.py   --results_dir results/cade_300r   --outdir figures/cade_main   --tail_window 20

---
## One-Command Quick Test before full run

chmod +x quick_test.sh
./quick_test.sh

## One-Command Full Pipeliner run

chmod +x run_all.sh
./run_all.sh

## 📌 Notes

- telemetry_merged.csv is NOT included
- Generate using merge script
- Ensure consistent CSV schema

---

## 🏷 Topics

federated-learning, reinforcement-learning, ppo, edge-computing, 
cloud-computing
