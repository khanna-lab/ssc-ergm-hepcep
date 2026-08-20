# =============================================================================
# Module 4 — Exercise: what degeneracy looks like
# Live concept: push a degree term too far and watch the fit blow up.
# Solution key: R/04-failure-modes.R
# =============================================================================

source(here::here("R", "00-setup.R"))

# The dyad-independent mixing block (same as Module 3).
f_mix <- net ~ edges +
  nodemix("sex",      levels2 = -1) +
  nodemix("young",    levels2 = -1) +
  nodemix("race.num", levels2 = -1) +
  nodematch("chicago")

# Cap the number of MCMLE iterations so a *degenerate* fit gives up quickly
# instead of grinding for a long time before it errors.
ctrl <- control.ergm(MCMLE.maxit = 20)

# ---- Run this: trigger degeneracy -------------------------------------------
# odegree(0:2) fits fine at n = 1000; odegree(0:3) is DEGENERATE -- ergm errors
# out. Read the message: it flags simulated networks nothing like the data
# ("...exceeds that in the observed by a factor of more than 20...").
ergm(update(f_mix, ~ . + odegree(0:3)),
     target.stats = c(ts_mix, odeg_target(0:3)),
     control = ctrl, eval.loglik = FALSE)

# ---- Your turn: back off to odegree(0:2) ------------------------------------
# Re-fit with odegree(0:2); it should converge and simulate a sensible edge count.
# TODO: fit_ok <- ergm(update(f_mix, ~ . + odegree(0:2)),
#                      target.stats = c(ts_mix, odeg_target(0:2)),
#                      control = ctrl, eval.loglik = FALSE)
# TODO: network.edgecount(simulate(fit_ok, nsim = 1))    # near the target now?

# --- Try at home -------------------------------------------------------------
# a. Read the sampler: mcmc.diagnostics(fit_ok). Healthy traces look like flat
#    "fuzzy caterpillars"; drifting traces signal non-convergence.
# b. gof(fit_ok, GOF = ~ idegree + odegree - model) -- do the degree
#    distributions line up? (Full version: R/04-failure-modes.R.)
