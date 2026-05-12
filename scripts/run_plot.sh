#!/usr/bin/env bash
set -euo pipefail

# CADE 2026 plotting script
# Usage:
#   bash scripts/run_plot.sh all        # original plots
#   bash scripts/run_plot.sh fig5       # Figure 5 only
#   bash scripts/run_plot.sh overhead   # Figure 6 + controller overhead table
#   bash scripts/run_plot.sh reviewer   # Figure 5 + Figure 6 + table

MODE="${1:-reviewer}"
TAIL_WINDOW="20"
PLOT_START_ROUND="281"

mkdir -p outputs/plots

plot_original_all() {
  echo "Plotting original CADE 2026 results..."
  python3 src/plot_cade_results.py \
    --results_dir outputs \
    --outdir outputs/plots \
    --tail_window "$TAIL_WINDOW"
}

plot_fig5_reward() {
  echo "Plotting Reviewer Fig. 5 reward convergence..."
  python3 src/plot_cade_results.py \
    --results_dir outputs/afrl_runs_fig5_reward_10clients \
    --outdir outputs/afrl_runs_fig5_reward_10clients/final_plots \
    --tail_window "$TAIL_WINDOW" \
    --plot_start_round "$PLOT_START_ROUND"

  ls -lh outputs/afrl_runs_fig5_reward_10clients/final_plots/Figure5_reward_convergence.png
}

plot_overhead() {
  echo "Combining Reviewer Fig. 6 overhead results..."
  mkdir -p outputs/afrl_runs_overhead_all

  cp outputs/afrl_runs_overhead_n2/*.json outputs/afrl_runs_overhead_all/
  cp outputs/afrl_runs_overhead_n5/*.json outputs/afrl_runs_overhead_all/
  cp outputs/afrl_runs_overhead_n10/*.json outputs/afrl_runs_overhead_all/

  echo "Plotting Reviewer Fig. 6 controller overhead and table..."
  python3 src/plot_cade_results.py \
    --results_dir outputs/afrl_runs_overhead_all \
    --outdir outputs/afrl_runs_overhead_all/final_plots \
    --tail_window "$TAIL_WINDOW" \
    --plot_start_round "$PLOT_START_ROUND"

  ls -lh outputs/afrl_runs_overhead_all/final_plots/Figure6_controller_overhead.png
  ls -lh outputs/afrl_runs_overhead_all/final_plots/Table_controller_overhead.csv
  cat outputs/afrl_runs_overhead_all/final_plots/Table_controller_overhead.csv
}

case "$MODE" in
  all)
    plot_original_all
    ;;
  fig5)
    plot_fig5_reward
    ;;
  overhead)
    plot_overhead
    ;;
  reviewer)
    plot_fig5_reward
    plot_overhead
    ;;
  *)
    echo "Unknown mode: $MODE"
    echo "Use one of: all, fig5, overhead, reviewer"
    exit 1
    ;;
esac
