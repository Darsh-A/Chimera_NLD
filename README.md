# Chimera States — NLD Term Project (IDC-402)

Simulation of chimera states in the Abrams–Strogatz model of nonlocally coupled phase oscillators.

## Structure

```
main.py          entry point
src/
  config.py      all parameters
  funcs.py       ODE right-hand side, order parameters, drift frequency
  utils.py       initial conditions, solver wrapper, chimera retry
  plots.py       all figure generation
plots/           generated figures and animation (gitignored)
report/
  paper.typ      typst source
  paper.pdf      compiled report
  references.bib citations
resources/       reference papers
```

## Setup

```bash
uv sync
uv run main.py
```

## Config (`src/config.py`)

Set `LITE = True` for a quick run (~1 min, reduced N and shorter integration).  
Set `LITE = False` for full-quality results matching the report.

Key parameters:

| Parameter | LITE | FULL |
|-----------|------|------|
| N | 256 | 512 |
| T_SPAN | (0, 500) | (0, 5000) |
| SWEEP_N_ALPHA | 8 | 20 |

`A`, `ALPHA`, and other physics parameters are fixed to match Abrams & Strogatz (2004) Fig. 1.

## Report

Compiled PDF: `report/paper.pdf`  
To recompile: `typst compile --root . report/paper.typ report/paper.pdf`
