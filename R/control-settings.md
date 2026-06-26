# ERGM fitting controls: defaults vs. what we use

Reference for the `control.ergm()` settings in the workshop pipeline
(`R/02-sequential.R`) and how they relate to the full HepCEP pipeline. The
override story comes from the statnet_help thread "Upgrading from ERGM v3.10 to
v4.6" (Khanna / Butts / Krivitsky / Goodreau, 2024).

## Comparison

| Setting | ergm 4.x default | Workshop (`fit_control`) | Full pipeline | Controls |
|---|---|---|---|---|
| `main.method` | `"MCMLE"` | `"Stochastic-Approximation"` | `"Stochastic-Approximation"` | Estimation algorithm (G-T-H vs SA) |
| `MCMLE.termination` | `"Hummel"` | not set -> `"Hummel"` | `"Hotelling"` | MCMLE convergence-detection rule |
| `MCMC.effectiveSize` | adaptive (non-`NULL`) | not set -> adaptive | `NULL` | Adaptive effective-sample-size targeting; `NULL` = fixed thinning |
| `MCMC.interval` | ~1024 (4.x adapts) | `1e4` | `1e6` | MCMC thinning between draws |
| `MCMC.samplesize` | ~1024 | `1e4` | `1e6` | Draws per MCMLE step |
| `MCMLE.maxit` | 60 | 60 | 500 | Max MCMLE iterations |
| `SAN` | `control.san()` defaults | not set -> defaults | `control.san(SAN.maxit = 500, SAN.nsteps = 1e8)` | Starting-network annealing |
| `eval.loglik` (an `ergm()` arg) | `TRUE` | `FALSE` | `FALSE` | Skip log-likelihood eval (faster) |

Defaults are for ergm v4.x and several are adaptive / version-dependent; confirm
exact values with `?control.ergm` or `args(control.ergm)` in your session.

## When do you need to override? (the message)

The heavy overrides were driven by **scale**, not by the model form. At n = 32k
with degree and distance dependence, the ergm 4.x defaults (MCMLE + Hummel) failed
to converge; switching to Stochastic-Approximation (which "fails more gracefully",
per Butts) plus Hotelling convergence detection brought the simulated statistics
close to the targets. Notably, Krivitsky's first suggestion went the other way:
"have you tried running ergm() without overriding any of the control parameters?"

On the **n = 1000 workshop data** the model is much smaller and less dependent, so
the 4.x defaults will very likely converge on their own. That contrast is the
lesson:

- **Start with the defaults** and let the adaptive algorithm work.
- **Override only when convergence fails**, smallest change first: increase MCMC
  thinning (`MCMC.interval`) -> switch to `main.method = "Stochastic-Approximation"`
  -> set `MCMLE.termination = "Hotelling"` and `MCMC.effectiveSize = NULL`.
- **Diagnose with a second simulation** (`gof()` or `simulate()`), not the ergm
  object's penultimate MCMC diagnostics. (The "converged but targets not matched"
  confusion in the thread came from reading diagnostics off the fit object.)
- Fitting to **target stats** (not an observed network) adds a wrinkle: with
  estimation error in the targets, no ERGM in the family may match them exactly, so
  "expected stats = targets" can be an imperfect convergence test.

## Try it (the experiment for n = 1000)

```r
source("R/00-setup.R")
f <- net ~ edges + nodemix("sex", levels2 = -1) + nodemix("young", levels2 = -1) +
           nodemix("race.num", levels2 = -1) + nodematch("chicago") +
           idegree(0:1) + odegree(0:1)
ts <- c(ts_mix, ideg_target(0:1), odeg_target(0:1))

# (a) defaults: no control overrides
fit_default <- ergm(f, target.stats = ts, eval.loglik = FALSE)

# (b) override recipe (full-pipeline style, scaled MCMC)
fit_override <- ergm(f, target.stats = ts, eval.loglik = FALSE,
  control = control.ergm(main.method = "Stochastic-Approximation",
                         MCMLE.termination = "Hotelling",
                         MCMC.effectiveSize = NULL))

# Compare via a second simulation, not the fit object's diagnostics:
plot(gof(fit_default ~ idegree + odegree))
```

## The override recipe (full pipeline)

```r
control.ergm(
  main.method        = "Stochastic-Approximation",
  MCMLE.termination  = "Hotelling",
  MCMC.effectiveSize = NULL,
  MCMC.interval      = 1e6,
  MCMC.samplesize    = 1e6,
  SAN = control.san(SAN.maxit = 500, SAN.nsteps = 1e8)
)
```
