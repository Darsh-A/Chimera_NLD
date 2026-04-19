import numpy as np

# Lite mode = faster almost 1 min
LITE = False

# Paper parameters (Abrams & Strogatz 2004, Fig 1)
N = 256 if LITE else 512
A = 0.995
ALPHA = np.pi / 2 - 0.18 # beta = 0.18
OMEGA = 0.0

# Initial conditions
IC_AMPLITUDE = 6.0
IC_KAPPA = 0.76

# Integration
T_SPAN = (0, 500) if LITE else (0, 5000)
T_POINTS = 200 if LITE else 1000
MAX_STEP = 0.5 if LITE else 0.1

# Chimera survival check
PROBE_T = 100 if LITE else 500
R_THRESHOLD = 0.93
MAX_RETRIES = 5 if LITE else 10

# Bifurcation sweep
SWEEP_T_SPAN = (0, 300) if LITE else (0, 2000)
SWEEP_T_POINTS = 100 if LITE else 400
SWEEP_N_ALPHA = 8 if LITE else 20

# Diagnostics
LOCAL_ORDER_WINDOW = 20 if LITE else 40

PLOT_DIR = "plots"
