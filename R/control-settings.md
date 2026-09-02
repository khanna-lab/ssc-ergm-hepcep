# ERGM fitting controls: defaults vs. what we use

Reference for the `control.ergm()` settings in the workshop pipeline
(`R/02-sequential.R`) and how they relate to the full HepCEP pipeline. The
override story comes from the statnet_help thread
[`correspondence/ergm-statnet-2024.md`](../correspondence/ergm-statnet-2024.md),
"Upgrading from ERGM v3.10 to
v4.6" (Khanna / Butts / Krivitsky / Goodreau, 2024).

## Takeaway

On the n=1000 tutorial dataset, the ergm 4.x defaults converge fine through the
mixing terms and a **single** degree type (in- or out-degree). Once **both in- and
out-degree** terms are included, the defaults no longer converge cleanly, whereas
the ergm-3.x-style overrides (Stochastic-Approximation + Hotelling termination +
`MCMC.effectiveSize = NULL`) do. So those overrides appear **necessary for the full
degree specification** — the in/out-degree combination is the threshold. That is
one of the core messages of the tutorial, and it mirrors the n=32k experience in
the email thread below.

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

## What we observed (n = 1000)

Running `R/test-sequential-defaults.R` showed a more nuanced picture than "defaults
just work":

- The **mixing block** and **`+ odegree(0:1)`** converged cleanly with defaults
  (step length held at 1.0; log-likelihood improvements shrank to ~0.02 before
  convergence).
- The **full final model (`idegree(0:1) + odegree(0:1)` together)** is the hard case
  even at this scale: step lengths collapsed (1.0 -> ~0.02) while the log-likelihood
  kept jumping by 2-3 per iteration and the estimating equations never entered the
  tolerance region. That is the same wall hit at n = 32k, reproduced in miniature.

So the message: defaults handle the mixing and single-degree models; the combined
in/out-degree model is where the SA + Hotelling overrides earn their place. The test
script now fits that final model both ways (A: defaults, B: override recipe) and
compares simulated means to the targets.

> **Observational note (not yet rigorously measured):** watching the console, the
> defaults appeared to *struggle more* than the 3.x-style overrides on the full
> degree model (erratic, collapsing step lengths; estimating equations not settling
> into the tolerance region). This is an impression from the fitting output, not a
> formal comparison; the A/B fit in `test-sequential-defaults.R` is what would
> confirm it (compare convergence and simulated-mean-vs-target across the two).

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
