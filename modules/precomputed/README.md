# Precomputed fits

Generated artifacts that the module slides read/embed instead of computing
results at render time. This keeps rendering fast and fully reproducible — all
seed-sensitive output (network layouts, simulations, MCMC fits, GOF) is fixed
here, and the slides' code chunks are illustrative only.

| File | Produced by | Read by |
|------|-------------|---------|
| `intro.rds` | `R/precompute-intro.R` | `modules/01-ergm-intro.qmd` (summaries, coefficients, both degree GOF objects) |
| `netplot.png` | `R/precompute-intro.R` | `modules/01-ergm-intro.qmd` ("What does it look like?") |
| `obs-vs-sim.png` | `R/precompute-intro.R` | `modules/01-ergm-intro.qmd` ("Observed vs. simulated") |

Regenerate when a model spec or figure changes:

```bash
Rscript R/precompute-intro.R
```

These artifacts are committed so the slides render on any machine (and on
Posit Cloud) without running the fits.
