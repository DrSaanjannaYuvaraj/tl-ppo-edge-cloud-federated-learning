#!/bin/bash

set -e

echo "=========================================="
echo "🚀 TL-PPO FULL PIPELINE (ENHANCED)"
echo "=========================================="

# Create logs dir
mkdir -p logs

# -------------------------------
# Step 1: Merge dataset
# -------------------------------
echo "📊 Merging telemetry data..."
python scripts/merge_telemetry.py   --input_dir data   --output_csv data/telemetry_merged.csv

echo "✅ Merge completed"

# -------------------------------
# Step 2: Start clients
# -------------------------------
echo "🖥️ Starting clients..."

PIDS=()

for i in {1..10}
do
  PORT=$((7999 + i))
  echo "Starting client $i on port $PORT"

  python client/client_api.py     --client_id $i     --csv data/telemetry_client${i}.csv     --port $PORT     --class_map shared/class_map.json     --scaler_path shared/scaler.json     > logs/client_${i}.log 2>&1 &

  PIDS+=($!)
done

# -------------------------------
# Step 3: Health check
# -------------------------------
echo "🔍 Checking client health..."

sleep 5

for i in {1..10}
do
  PORT=$((7999 + i))
  echo -n "Client $i (port $PORT): "

  if curl -s http://127.0.0.1:$PORT/health | grep -q "ok"; then
    echo "✅ OK"
  else
    echo "❌ FAILED"
    echo "Stopping all clients..."
    for pid in "${PIDS[@]}"; do kill $pid 2>/dev/null || true; done
    exit 1
  fi
done

echo "✅ All clients healthy"

# -------------------------------
# Step 4: Run experiment
# -------------------------------
echo "🧠 Running experiment..."

START_TIME=$(date +%s)

python server/server_experiment_cade.py   --csv data/telemetry_merged.csv   --label_col scenario   --clients "http://127.0.0.1:8000,http://127.0.0.1:8001,http://127.0.0.1:8002,http://127.0.0.1:8003,http://127.0.0.1:8004,http://127.0.0.1:8005,http://127.0.0.1:8006,http://127.0.0.1:8007,http://127.0.0.1:8008,http://127.0.0.1:8009"   --rounds 300   --seeds 42,43,44,45,46   --strategies fedavg,random,greedy,dqn,ddqn,tl_ppo   --outdir results/cade_300r   | tee logs/experiment.log

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo "✅ Experiment completed in ${DURATION}s"

# -------------------------------
# Step 5: Generate plots
# -------------------------------
echo "📈 Generating figures..."

python server/plot_cade_results.py   --results_dir results/cade_300r   --outdir figures/cade_main   --tail_window 20   | tee logs/plot.log

echo "✅ Figures generated"

# -------------------------------
# Step 6: Cleanup clients
# -------------------------------
echo "🧹 Stopping clients..."

for pid in "${PIDS[@]}"
do
  kill $pid 2>/dev/null || true
done

echo "=========================================="
echo "🎉 ALL DONE"
echo "⏱ Total time: ${DURATION}s"
echo "📁 Results: results/cade_300r"
echo "📊 Figures: figures/cade_main"
echo "📜 Logs: logs/"
echo "=========================================="
