import numpy as np


def kuramoto_chimera(t, theta, x, N, A, alpha, omega):
    """
    Abrams and Strogatz chimera model RHS for solve_ivp.
    G(x) = 1 + A*cos(x), H(theta) = sin(theta + alpha).
    """
    theta_diff = theta[:, None] - theta[None, :]
    x_diff = x[:, None] - x[None, :]
    G = 1 + A * np.cos(x_diff)
    interaction = np.sin(theta_diff + alpha)
    return omega - np.sum(G * interaction, axis=1) / N


def local_order_parameter(theta, window):
    """
    Sliding-window local order parameter |z(x)|.
    For each oscillator i, averages exp(i*theta_j) over a window
    of size 2*window+1 centered at i (periodic boundary).
    """
    N = len(theta)
    z_mag = np.empty(N)
    for i in range(N):
        indices = np.arange(i - window, i + window + 1) % N
        z_mag[i] = np.abs(np.mean(np.exp(1j * theta[indices])))
    return z_mag


def global_order_parameter(theta):
    """R = |1/N * sum_j exp(i*theta_j)|"""
    return np.abs(np.mean(np.exp(1j * theta)))


def kernel_order_parameter(theta, x, N, A):
    """
    Abrams & Strogatz Eq. 3:
        R(x) e^{iTheta(x)} = integral G(x−x') e^{itheta(x')} dx'    
    with G(x) = (1+A cos x)/(2π).

    Returns R(x) and Theta(x) arrays matching the paper's Fig 1(b,c).
    """
    x_diff = x[:, None] - x[None, :]
    G = (1 + A * np.cos(x_diff)) / (2 * np.pi)
    dx = 2 * np.pi / N
    Z = G @ (np.exp(1j * theta)) * dx
    R = np.abs(Z)
    Theta = np.angle(Z)
    return R, Theta


def mean_drift_frequency(sol, t_transient_frac=0.5):
    """
    Time-averaged angular velocity of each oscillator:
        delta_i ≈ (theta_i(t_end) − theta_i(t_cut)) / (t_end − t_cut)
    Uses unwrapped phases. Matches the inset panels of Fig 4.
    """ 
    t_cut = int(t_transient_frac * len(sol.t))
    theta_unwrap = np.unwrap(sol.y, axis=1)
    delta = (theta_unwrap[:, -1] - theta_unwrap[:, t_cut]) / (sol.t[-1] - sol.t[t_cut])
    return delta
