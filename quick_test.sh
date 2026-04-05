#!/bin/bash

set -e

echo "=========================================="
echo "⚡ TL-PPO QUICK TEST (10 ROUNDS)"
echo "=========================================="

mkdir -p logs results/quick_test figures/quick_test

PIDS=()

cleanup() {
  echo "🧹 Cleaning up client processes..."
  for pid in "${PIDS[@]}"; do
    kill "$pid" 2>/dev/null || true
  done
}
trap cleanup EXIT

echo "📊 Merging telemetry data..."
python scripts/merge_telemetry.py   --input_dir data   --output_csv data/telemetry_merged.csv   --strict_schema   --sort

echo "🖥️ Starting clients..."
for i in {1..10}
do
  PORT=$((7999 + i))
  echo "Starting client $i on port $PORT"
  python client/client_api.py     --client_id $i     --csv data/telemetry_client${i}.csv     --port $PORT     --class_map shared/class_map.json     --scaler_path shared/scaler.json     > logs/quick_client_${i}.log 2>&1 &
  PIDS+=($!)
done

echo "🔍 Checking client health..."
sleep 5
for i in {1..10}
do
  PORT=$((7999 + i))
  echo -n "Client $i (port $PORT): "
  if curl -s http://127.0.0.1:$PORT/health | grep -q "ok"; then
    echo "OK"
  else
    echo "FAILED"
    exit 1
  fi
done

echo "🧠 Running quick validation experiment..."
python server/server_experiment_cade.py   --csv data/telemetry_merged.csv   --label_col scenario   --clients "http://127.0.0.1:8000,http://127.0.0.1:8001,http://127.0.0.1:8002,http://127.0.0.1:8003,http://127.0.0.1:8004,http://127.0.0.1:8005,http://127.0.0.1:8006,http://127.0.0.1:8007,http://127.0.0.1:8008,http://127.0.0.1:8009"   --rounds 10   --seeds 42   --strategies fedavg,greedy,tl_ppo   --outdir results/quick_test   | tee logs/quick_test_experiment.log

echo "📈 Generating quick figures..."
python server/plot_cade_results.py   --results_dir results/quick_test   --outdir figures/quick_test   --tail_window 5   --sensitivity_windows 5 10   | tee logs/quick_test_plot.log

echo "=========================================="
echo "✅ QUICK TEST PASSED"
echo "📁 Results: results/quick_test"
echo "📊 Figures: figures/quick_test"
echo "📜 Logs: logs/"
echo "=========================================="
