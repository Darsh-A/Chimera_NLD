from pathlib import Path

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation

from src.funcs import (
    local_order_parameter,
    global_order_parameter,
    kernel_order_parameter,
    mean_drift_frequency,
)
from src.utils import make_initial_conditions, run_simulation
from src.config import PLOT_DIR


def save_fig(fig, filename, dpi=200):
    out = Path(PLOT_DIR)
    out.mkdir(parents=True, exist_ok=True)
    path = out / filename
    fig.savefig(path, dpi=dpi, bbox_inches="tight")
    print(f"Saved → {path}")


# Space-Time plot

def plot_space_time(sol, x, title=None, filename="space_time.png"):
    theta = (sol.y + np.pi) % (2 * np.pi) - np.pi
    fig, ax = plt.subplots(figsize=(10, 5))
    pcm = ax.pcolormesh(
        sol.t, x, theta, shading="auto", cmap="twilight", vmin=-np.pi, vmax=np.pi
    )
    fig.colorbar(pcm, ax=ax, label=r"$\theta$")
    ax.set_xlabel("Time")
    ax.set_ylabel("Oscillator position $x$")
    ax.set_title(title or "Space–Time plot")
    plt.tight_layout()
    if filename:
        save_fig(fig, filename)
    return fig


# Sliding-window local order parameter |z(x)|

def plot_local_order(sol, x, window, title=None, filename="local_order.png"):
    final_theta = sol.y[:, -1]
    z_mag = local_order_parameter(final_theta, window)

    fig, ax = plt.subplots(figsize=(8, 4))
    ax.plot(x, z_mag, lw=1.5, color="tab:red")
    ax.set_xlabel("Position on ring $x$")
    ax.set_ylabel(r"$|z(x)|$")
    ax.set_ylim(-0.05, 1.05)
    ax.set_title(title or rf"Local order parameter (window = {window})")
    ax.axhline(1.0, ls="--", color="grey", lw=0.8)
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    if filename:
        save_fig(fig, filename)
    return fig


# Bifurcation sweep

def plot_bifurcation_sweep(
    x, N, A, omega, t_span, t_points, alpha_values,
    t_transient_frac=0.8, title=None,
    filename="bifurcation_sweep.png", max_step=0.5,
):
    R_values = np.empty(len(alpha_values))

    for idx, alpha in enumerate(alpha_values):
        theta0 = make_initial_conditions(x, N)
        sol = run_simulation(
            theta0, x, N, A, alpha, omega, t_span, t_points, max_step=max_step,
        )
        t_cut = int(t_transient_frac * sol.y.shape[1])
        steady = sol.y[:, t_cut:]
        R_snap = np.array([
            global_order_parameter(steady[:, k]) for k in range(steady.shape[1])
        ])
        R_values[idx] = np.mean(R_snap)
        print(f"  [{idx+1}/{len(alpha_values)}]  α = {alpha:.4f}  →  <R> = {R_values[idx]:.4f}")

    fig, ax = plt.subplots(figsize=(8, 4))
    ax.plot(alpha_values, R_values, "o-", ms=4, lw=1.2, color="tab:blue")
    ax.set_xlabel(r"$\alpha$")
    ax.set_ylabel(r"$\langle R \rangle$")
    ax.set_title(title or r"Bifurcation sweep: global order parameter vs $\alpha$")
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    if filename:
        save_fig(fig, filename)
    return fig, alpha_values, R_values


# Phase snapshots at key time-steps

def plot_phase_snapshots(sol, x, title_prefix="", filename="phase_snapshots.png"):
    """
    Grid of phase snapshots at key moments:
    t=0 (IC), ~10% (early), ~50% (mid), ~90% (late), final.
    Shows the chimera forming and settling instead of a single random frame.
    """
    n_t = sol.y.shape[1]
    frame_indices = [0, n_t // 10, n_t // 2, int(0.9 * n_t), n_t - 1]
    labels = ["IC", "early", "mid", "late", "final"]

    fig, axes = plt.subplots(1, 5, figsize=(18, 3.5), sharey=True)

    for ax, idx, label in zip(axes, frame_indices, labels):
        phases = (sol.y[:, idx] + np.pi) % (2 * np.pi) - np.pi
        ax.scatter(x, phases, s=4, color="tab:blue", edgecolors="none")
        ax.set_title(f"{label}  (t = {sol.t[idx]:.0f})")
        ax.set_xlabel("$x$")
        ax.set_ylim(-np.pi - 0.3, np.pi + 0.3)
        ax.grid(True, alpha=0.3)

    axes[0].set_ylabel(r"Phase $\theta$")
    fig.suptitle(f"{title_prefix}Phase evolution", fontsize=13)
    plt.tight_layout()
    if filename:
        save_fig(fig, filename)
    return fig


# Paper Figure 1 reproduction: θ(x), R(x), Θ(x)

def plot_paper_fig1(sol, x, N, A, title_prefix="", filename="paper_fig1.png"):
    """
    Reproduces Fig 1(a-c) of Abrams and Strogat
      (a) phase snapshot theta(x)
      (b) kernel-weighted local coherence R(x)
      (c) local average phase Theta(x)
    """
    final_theta = (sol.y[:, -1] + np.pi) % (2 * np.pi) - np.pi
    R, Theta = kernel_order_parameter(sol.y[:, -1], x, N, A)

    fig, axes = plt.subplots(3, 1, figsize=(7, 8), sharex=True)

    axes[0].scatter(x, final_theta, s=4, color="tab:blue", edgecolors="none")
    axes[0].set_ylabel(r"$\theta$")
    axes[0].set_title(f"{title_prefix}(a) Phase snapshot")
    axes[0].set_ylim(-np.pi - 0.3, np.pi + 0.3)
    axes[0].grid(True, alpha=0.3)

    axes[1].plot(x, R, lw=1.5, color="tab:red")
    axes[1].set_ylabel(r"$R(x)$")
    axes[1].set_title("(b) Local coherence $R(x)$  [Eq. 3]")
    axes[1].set_ylim(0, 1.05)
    axes[1].grid(True, alpha=0.3)

    axes[2].plot(x, Theta, lw=1.5, color="tab:green")
    axes[2].set_ylabel(r"$\Theta(x)$")
    axes[2].set_xlabel("Position on ring $x$")
    axes[2].set_title(r"(c) Local average phase $\Theta(x)$  [Eq. 3]")
    axes[2].grid(True, alpha=0.3)

    plt.tight_layout()
    if filename:
        save_fig(fig, filename)
    return fig


# Mean drift frequency Δ(x)

def plot_drift_frequency(sol, x, title=None, filename="drift_frequency.png"):
    delta = mean_drift_frequency(sol)

    fig, ax = plt.subplots(figsize=(8, 4))
    ax.plot(x, delta, lw=1.2, color="tab:purple")
    ax.set_xlabel("Position on ring $x$")
    ax.set_ylabel(r"$\langle \dot{\theta} \rangle$")
    ax.set_title(title or r"Mean drift frequency $\Delta(x)$")
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    if filename:
        save_fig(fig, filename)
    return fig


# Evolution animation

def animate_evolution(
    sol, x, window, fps=30,
    filename="chimera_evolution.mp4", title_prefix="",
):
    theta_all = (sol.y + np.pi) % (2 * np.pi) - np.pi
    n_frames = theta_all.shape[1]

    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(9, 6), sharex=True)

    scat = ax1.scatter(x, theta_all[:, 0], s=6, c="tab:blue", edgecolors="none")
    ax1.set_ylim(-np.pi - 0.3, np.pi + 0.3)
    ax1.set_ylabel(r"Phase $\theta$")
    ax1.grid(True, alpha=0.3)
    ax1.set_title("")

    z0 = local_order_parameter(sol.y[:, 0], window)
    (line,) = ax2.plot(x, z0, lw=1.5, color="tab:red")
    ax2.set_ylim(-0.05, 1.05)
    ax2.set_xlabel("Position on ring $x$")
    ax2.set_ylabel(r"$|z(x)|$")
    ax2.axhline(1.0, ls="--", color="grey", lw=0.8)
    ax2.grid(True, alpha=0.3)
    fig.tight_layout()

    def _update(frame):
        phases = theta_all[:, frame]
        scat.set_offsets(np.column_stack([x, phases]))
        z = local_order_parameter(sol.y[:, frame], window)
        line.set_ydata(z)
        ax1.set_title(f"{title_prefix}t = {sol.t[frame]:.1f}")
        return scat, line

    anim = FuncAnimation(fig, _update, frames=n_frames, interval=1000 // fps, blit=True)

    out = Path(PLOT_DIR)
    out.mkdir(parents=True, exist_ok=True)
    path = out / filename

    try:
        anim.save(str(path), writer="ffmpeg", fps=fps, dpi=150)
    except Exception:
        gif_path = path.with_suffix(".gif")
        print("ffmpeg not found, falling back to .gif via pillow")
        anim.save(str(gif_path), writer="pillow", fps=fps, dpi=100)
        path = gif_path

    plt.close(fig)
    print(f"Saved → {path}")
