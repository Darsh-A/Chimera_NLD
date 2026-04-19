import numpy as np
import matplotlib.pyplot as plt

from src.config import (
    LITE, N, A, ALPHA, OMEGA, T_SPAN, T_POINTS, MAX_STEP, LOCAL_ORDER_WINDOW,
    IC_AMPLITUDE, IC_KAPPA, PROBE_T, R_THRESHOLD, MAX_RETRIES,
    SWEEP_T_SPAN, SWEEP_T_POINTS, SWEEP_N_ALPHA,
)
from src.utils import run_with_chimera_check
from src.plots import (
    plot_space_time,
    plot_local_order,
    plot_phase_snapshots,
    plot_paper_fig1,
    plot_drift_frequency,
    plot_bifurcation_sweep,
    animate_evolution,
)

x = np.linspace(-np.pi, np.pi, N, endpoint=False)

mode = "LITE" if LITE else "FULL"
print(f"[{mode}]  N={N}, T={T_SPAN[1]}, α={ALPHA:.4f}")

# Single simulation with chimera-survival retry
sol = run_with_chimera_check(
    x, N, A, ALPHA, OMEGA, T_SPAN, T_POINTS,
    max_step=MAX_STEP, amplitude=IC_AMPLITUDE, kappa=IC_KAPPA,
    probe_t=PROBE_T, R_threshold=R_THRESHOLD, max_retries=MAX_RETRIES,
)

plot_phase_snapshots(sol, x, title_prefix=f"α = {ALPHA:.3f}   ")
plot_space_time(sol, x, title=f"Space–Time  (α = {ALPHA:.3f})")
plot_local_order(sol, x, LOCAL_ORDER_WINDOW, title=f"|z(x)|  (α = {ALPHA:.3f})")
plot_paper_fig1(sol, x, N, A, title_prefix=f"α = {ALPHA:.3f}  ")
plot_drift_frequency(sol, x, title=f"Mean drift frequency  (α = {ALPHA:.3f})")

print("Rendering evolution video …")
animate_evolution(sol, x, LOCAL_ORDER_WINDOW, title_prefix=f"α = {ALPHA:.3f}  ")

# Bifurcation sweep
alpha_sweep = np.linspace(1.2, np.pi / 2, SWEEP_N_ALPHA)
print("Running bifurcation sweep …")
plot_bifurcation_sweep(
    x, N, A, OMEGA, SWEEP_T_SPAN, SWEEP_T_POINTS, alpha_sweep, max_step=MAX_STEP,
)

plt.show()
