import numpy as np
from scipy.integrate import solve_ivp

from src.funcs import kuramoto_chimera, global_order_parameter


def make_initial_conditions(x, N, amplitude=6.0, kappa=0.76):
    """
    Gaussian-bump perturbation: phi(x) = a · exp(−kappa x²) · U(−½, ½).
    Paper uses a=6, b=30 for N=256 fixed-step RK4.
    kappa=0.76 is wider and nucleates reliably with adaptive RK45 at larger N.
    """
    envelope = amplitude * np.exp(-kappa * x**2)
    noise = np.random.uniform(-0.5, 0.5, size=N)
    return envelope * noise


def run_simulation(
    theta0, x, N, A, alpha, omega, t_span, t_points,
    method="RK45", max_step=0.5,
):
    t_eval = np.linspace(t_span[0], t_span[1], t_points)
    sol = solve_ivp(
        fun=kuramoto_chimera,
        t_span=t_span,
        y0=theta0,
        t_eval=t_eval,
        args=(x, N, A, alpha, omega),
        method=method,
        max_step=max_step,
    )
    return sol


def run_with_chimera_check(
    x, N, A, alpha, omega, t_span, t_points,
    max_step=0.5, amplitude=6.0, kappa=0.76,
    probe_t=500, R_threshold=0.93, max_retries=10,
):
    """
    Retry loop: run a cheap probe to t=probe_t, check if the chimera
    is still alive (global order parameter < R_threshold).  If dead, reseed and retry.
    Once a surviving initial condition is found, run the full simulation with it.
    """
    for attempt in range(1, max_retries + 1):
        theta0 = make_initial_conditions(x, N, amplitude=amplitude, kappa=kappa)

        probe_sol = run_simulation(
            theta0, x, N, A, alpha, omega,
            (0, probe_t), max(50, t_points // 10),
            max_step=max_step,
        )
        R_probe = global_order_parameter(probe_sol.y[:, -1])

        if R_probe < R_threshold:
            print(f"  Attempt {attempt}: chimera alive at t={probe_t}  (R = {R_probe:.3f})")
            sol = run_simulation(
                theta0, x, N, A, alpha, omega,
                t_span, t_points, max_step=max_step,
            )
            R_final = global_order_parameter(sol.y[:, -1])
            print(f"  Full run done  (R_final = {R_final:.3f})")
            return sol

        print(f"  Attempt {attempt}: chimera collapsed  (R = {R_probe:.3f}), retrying …")

    print(f"  WARNING: no chimera after {max_retries} attempts, returning last run")
    return run_simulation(
        theta0, x, N, A, alpha, omega, t_span, t_points, max_step=max_step,
    )
