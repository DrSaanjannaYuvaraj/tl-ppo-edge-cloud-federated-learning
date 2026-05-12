#!/usr/bin/env bash
set -euo pipefail

# CADE 2026 experiment launcher
# Replace CLIENT1_IP ... CLIENT10_IP before running.
# Usage:
#   bash scripts/run_server.sh all        # original full comparison run
#   bash scripts/run_server.sh fig5       # reviewer Fig. 5 reward convergence run
#   bash scripts/run_server.sh overhead   # reviewer Fig. 6 controller-overhead runs
#   bash scripts/run_server.sh reviewer   # fig5 + overhead together

MODE="${1:-reviewer}"

mkdir -p logs outputs

echo "Update CLIENT1_IP to CLIENT10_IP before running."

CSV="data/telemetry_merged.csv"
LABEL_COL="scenario"
ROUNDS="300"
SEEDS="42,43,44,45,46"
EPOCHS="3"
LR="0.001"
BATCH_SIZE="64"
ALPHA="1.0"
BETA="0.5"
GAMMA="0.3"

CLIENTS_2="http://CLIENT1_IP:8000,http://CLIENT2_IP:8000"
CLIENTS_5="http://CLIENT1_IP:8000,http://CLIENT2_IP:8000,http://CLIENT3_IP:8000,http://CLIENT4_IP:8000,http://CLIENT5_IP:8000"
CLIENTS_10="http://CLIENT1_IP:8000,http://CLIENT2_IP:8000,http://CLIENT3_IP:8000,http://CLIENT4_IP:8000,http://CLIENT5_IP:8000,http://CLIENT6_IP:8000,http://CLIENT7_IP:8000,http://CLIENT8_IP:8000,http://CLIENT9_IP:8000,http://CLIENT10_IP:8000"

COMMON_ARGS=(
  --csv "$CSV"
  --label_col "$LABEL_COL"
  --rounds "$ROUNDS"
  --seeds "$SEEDS"
  --epochs "$EPOCHS"
  --lr "$LR"
  --batch_size "$BATCH_SIZE"
  --alpha "$ALPHA"
  --beta "$BETA"
  --gamma "$GAMMA"
)

run_original_all() {
  echo "Starting original CADE 2026 full comparison run..."
  nohup python3 -u src/server_experiment_cade.py \
    "${COMMON_ARGS[@]}" \
    --clients "$CLIENTS_10" \
    --strategies fedavg,random,greedy,dqn,ddqn,tl_ppo \
    --outdir outputs/afrl_runs_cade_300r \
    > logs/run_cade_300r_all.log 2>&1 &
}

run_fig5_reward() {
  echo "Starting Reviewer Fig. 5 reward convergence run: dqn, ddqn, tl_ppo with 10 clients..."
  nohup python3 -u src/server_experiment_cade.py \
    "${COMMON_ARGS[@]}" \
    --clients "$CLIENTS_10" \
    --strategies dqn,ddqn,tl_ppo \
    --outdir outputs/afrl_runs_fig5_reward_10clients \
    > logs/run_fig5_reward_10clients.log 2>&1 &
}

run_overhead() {
  echo "Starting Reviewer Fig. 6 controller overhead run with 2 clients..."
  nohup python3 -u src/server_experiment_cade.py \
    "${COMMON_ARGS[@]}" \
    --clients "$CLIENTS_2" \
    --strategies tl_ppo \
    --outdir outputs/afrl_runs_overhead_n2 \
    > logs/run_overhead_n2.log 2>&1 &

  echo "Starting Reviewer Fig. 6 controller overhead run with 5 clients..."
  nohup python3 -u src/server_experiment_cade.py \
    "${COMMON_ARGS[@]}" \
    --clients "$CLIENTS_5" \
    --strategies tl_ppo \
    --outdir outputs/afrl_runs_overhead_n5 \
    > logs/run_overhead_n5.log 2>&1 &

  echo "Starting Reviewer Fig. 6 controller overhead run with 10 clients..."
  nohup python3 -u src/server_experiment_cade.py \
    "${COMMON_ARGS[@]}" \
    --clients "$CLIENTS_10" \
    --strategies tl_ppo \
    --outdir outputs/afrl_runs_overhead_n10 \
    > logs/run_overhead_n10.log 2>&1 &
}

case "$MODE" in
  all)
    run_original_all
    ;;
  fig5)
    run_fig5_reward
    ;;
  overhead)
    run_overhead
    ;;
  reviewer)
    run_fig5_reward
    run_overhead
    ;;
  *)
    echo "Unknown mode: $MODE"
    echo "Use one of: all, fig5, overhead, reviewer"
    exit 1
    ;;
esac

echo "Runs submitted. Check progress with:"
echo "  pgrep -af server_experiment_cade.py"
echo "  tail -f logs/run_fig5_reward_10clients.log"
echo "  tail -f logs/run_overhead_n2.log"
echo "  tail -f logs/run_overhead_n5.log"
echo "  tail -f logs/run_overhead_n10.log"
