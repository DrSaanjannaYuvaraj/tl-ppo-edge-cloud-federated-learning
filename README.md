# TL-PPO Edge–Cloud Artifact (End-to-End)

This repository reproduces the full TL-PPO experimental workflow including:
- Client API startup (10 clients)
- Server orchestration
- Multi-strategy experiment (FedAvg, DQN, DDQN, TL-PPO)
- Plotting and result export

This matches the execution workflow used in experiments.

---

## 🚀 Full Pipeline

### 1. Start Clients (ALL 10)
```bash
bash scripts/start_clients.sh
```

### 2. Check Clients from Server
```bash
bash scripts/check_clients.sh
```

### 3. Run Server Experiment
```bash
bash scripts/run_server.sh
```

### 4. Plot Results
```bash
bash scripts/run_plot.sh
```

---

## ⚠️ IMPORTANT

Before running:
- Replace CLIENT*_IP in scripts
- Ensure CSV files exist in data/
- Ensure config files exist in config/

---

## 📂 Structure

```
src/
config/
data/
scripts/
docs/
README.md
requirements.txt
```

---

## 📌 Notes
- This is TL-PPO baseline