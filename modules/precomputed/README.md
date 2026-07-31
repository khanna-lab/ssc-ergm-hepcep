# Precomputed fits

Generated artifacts that the module slides read/embed instead of computing
results at render time. Rendering stays fast and fully reproducible — all
seed-sensitive output (network layouts, simulations, MCMC fits, GOF) is fixed
here, and the slides' code chunks are illustrative only.

## Two-step build (fitting separated from GOF)

Fitting is the slow part (GWESP is MCMC), so it's split from goodness-of-fit:
run the fit once, then re-run GOF as often as you like without re-fitting.

```bash
Rscript R/precompute-intro-fit.R    # 1. fit the 3 models  -> out/intro-fits.rds (gitignored)
Rscript R/precompute-intro-gof.R    # 2. GOF + assemble     -> the files below
```

| File | Produced by | Read by |
|------|-------------|---------|
| `out/intro-fits.rds` *(intermediate, gitignored)* | `R/precompute-intro-fit.R` | `R/precompute-intro-gof.R` |
| `intro.rds` | `R/precompute-intro-gof.R` | `modules/01-ergm-intro.qmd` (summaries, coefficients, null/assortative/GWESP degree GOF) |
| `netplot.png` | `R/precompute-intro-gof.R` | `modules/01-ergm-intro.qmd` ("What does it look like?") |
| `obs-vs-sim.png` | `R/precompute-intro-gof.R` | `modules/01-ergm-intro.qmd` ("Observed vs. simulated") |

Re-run only the GOF step (step 2) when tweaking GOF seeds, terms, or figures.
Re-run the fit step (step 1) only when a model spec changes.

The `intro.rds` and `.png` files are committed so the slides render on any
machine (and on Posit Cloud) without running the fits.
