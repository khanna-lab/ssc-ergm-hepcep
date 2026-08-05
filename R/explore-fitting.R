# ============================================================================
# Sandbox: how ERGM fitting actually works (Module 3 background).
# Fit ONE hard model many ways and WATCH the algorithm run (verbose = TRUE).
# Run block by block, edit the control settings, re-run, compare.
# ============================================================================

library(here)
source(here("R", "00-setup.R"))   # gives net, ts_mix, odeg_target(), ideg_target(), ctrl

# --- The test case: Module 3's "hard step" (mixing block + in- AND out-degree) --
# It stresses the fitting algorithm, so differences between methods are visible.
f_mix <- net ~ edges +
  nodemix("sex",      levels2 = -1) +
  nodemix("young",    levels2 = -1) +
  nodemix("race.num", levels2 = -1) +
  nodematch("chicago")

fit_mix  <- ergm(f_mix, target.stats = ts_mix, eval.loglik = FALSE)
net_warm <- simulate(fit_mix, nsim = 1)                 # warm start (Module 3 idea)

f_hard  <- update(f_mix, net_warm ~ . + idegree(0:1) + odegree(0:1))
ts_hard <- c(ts_mix, ideg_target(0:1), odeg_target(0:1))

# ============================================================================
# 1.  MCMLE  vs  Stochastic Approximation   (main.method)
# ============================================================================
# The likelihood's normalizing constant is intractable, so BOTH methods are
# MCMC approximations — they differ in HOW they search for theta:
#
#   MCMLE (default): at the current theta, simulate networks, use them to
#     approximate the log-likelihood-ratio surface (importance sampling), then
#     take a maximizing (Newton-like) step. Fast near the answer; the importance
#     weights degrade — and it stalls — when theta starts far away.
#
#   Stochastic-Approximation (Robbins-Monro; Snijders 2002): directly solves the
#     moment equation  E_theta[stats] = target.  Each step: simulate, look at
#     (simulated mean - target), nudge theta a small amount that way with a
#     shrinking step size. Slower, but far more robust far from the answer —
#     which is why the hard step converges under SA where MCMLE stalls.

set.seed(1)
fit_mcmle <- ergm(f_hard, target.stats = ts_hard, eval.loglik = FALSE,
                  verbose = TRUE,                      # <- prints every iteration
                  control = control.ergm(
                    main.method     = "MCMLE",
                    MCMLE.maxit     = 60,
                    MCMC.interval   = 1e4,
                    MCMC.samplesize = 1e4))

set.seed(1)
fit_sa <- ergm(f_hard, target.stats = ts_hard, eval.loglik = FALSE,
               verbose = TRUE,
               control = control.ergm(
                 main.method     = "Stochastic-Approximation",
                 MCMLE.maxit     = 60,
                 MCMC.interval   = 1e4,
                 MCMC.samplesize = 1e4))

# Watch the console: how many iterations? did it reach tolerance / converge?
mcmc.diagnostics(fit_mcmle)   # traces should be flat "caterpillars" if healthy
mcmc.diagnostics(fit_sa)

# ============================================================================
# 2.  When does it STOP?   (MCMLE.termination — an MCMLE control)
# ============================================================================
#   "Hummel" (default): the adaptive "stepping" method (Hummel, Hunter & Handcock
#     2012). Shrinks each step (< full) so the simulated mean stays BETWEEN the
#     current fit and the target — keeps importance sampling stable — and grows the
#     step toward 1 as it nears the answer. Stops when step = 1 and stats within
#     tolerance.
#
#   "Hotelling": a Hotelling's T^2 test of "is the simulated mean of the statistics
#     different from the target?" Stops when it can no longer reject equality
#     (simulated ~ target within Monte Carlo error).

set.seed(1)
fit_hummel <- ergm(f_hard, target.stats = ts_hard, eval.loglik = FALSE, verbose = TRUE,
                   control = control.ergm(main.method = "MCMLE",
                                          MCMLE.termination = "Hummel",    # default
                                          MCMLE.maxit = 60))

set.seed(1)
fit_hotelling <- ergm(f_hard, target.stats = ts_hard, eval.loglik = FALSE, verbose = TRUE,
                      control = control.ergm(main.method = "MCMLE",
                                             MCMLE.termination = "Hotelling",
                                             MCMLE.maxit = 60))

# ---------------------------------------------------------------------------
#   MCMC.effectiveSize : adaptive vs. fixed sampling
# ---------------------------------------------------------------------------
# MCMC draws are autocorrelated, so N raw draws are worth fewer INDEPENDENT ones
# (the "effective" sample size).
#   = <number> : keep lengthening the chain until effective size reaches it (adaptive)
#   = NULL     : turn that off — use a FIXED MCMC.samplesize with fixed thinning
#                (MCMC.interval). Predictable; what our override recipe uses.

set.seed(1)
fit_fixed <- ergm(f_hard, target.stats = ts_hard, eval.loglik = FALSE, verbose = TRUE,
                  control = control.ergm(main.method = "Stochastic-Approximation",
                                         MCMC.effectiveSize = NULL,   # fixed sampling
                                         MCMC.interval = 1e4, MCMC.samplesize = 1e4))

# The real pipeline's "override recipe" — and what actually matters:
override_full <- control.ergm(          # what the full pipeline literally set
  main.method        = "Stochastic-Approximation",
  MCMLE.termination  = "Hotelling",
  MCMC.effectiveSize = NULL,
  MCMLE.maxit        = 60,
  MCMC.interval      = 1e4,
  MCMC.samplesize    = 1e4)

override_min <- control.ergm(           # equivalent under SA — the rest is inert
  main.method = "Stochastic-Approximation")

# RESOLVED (ergm 4.12 ?control.ergm): MCMLE.termination governs *MCMLE* only. Under
# Stochastic-Approximation the sampling is controlled by the SA.* family (SA.interval,
# SA.burnin, SA.samplesize, SA.phase3_n, SA.nsubphases), which ergm AUTO-SETS unless you
# override them. Docs: "SA.burnin, SA.interval, SA.samplesize: Sets the corresponding
# MCMC.* parameters when main.method='Stochastic-Approximation'." So under SA, the
# pipeline's MCMLE.termination = "Hotelling" and MCMC.* = 1e6 rode along inert — the only
# lever that changed the fit was main.method. Verify by diffing verbose output of
# override_full vs override_min: same convergence path.

# ---------------------------------------------------------------------------
# Things to try (edit + re-run):
#  - Fit f_hard from `net` instead of `net_warm` (drop the warm start) — does
#    MCMLE stall harder?
#  - Shrink MCMC.samplesize / MCMC.interval — watch the traces get noisier.
#  - `?control.ergm` — full list of knobs and your version's exact defaults.
# References: Snijders (2002); Hunter & Handcock (2006); Hummel, Hunter & Handcock (2012).
# ---------------------------------------------------------------------------
