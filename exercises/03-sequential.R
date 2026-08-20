# =============================================================================
# Module 3 — Exercise: sequential fitting with warm starts
# Live concept: fit a block, SIMULATE it, and use that network to warm-start
# the next, harder fit.
# Solution key: R/02-sequential.R
# =============================================================================

# Loads net, ts_mix, odeg_target(), ideg_target().
source(here::here("R", "00-setup.R"))

# The dyad-independent mixing block (edges + attribute mixing + geography).
f_mix <- net ~ edges +
  nodemix("sex",      levels2 = -1) +
  nodemix("young",    levels2 = -1) +
  nodemix("race.num", levels2 = -1) +
  nodematch("chicago")

# Light, FIXED-size MCMC so each fit runs quickly at n = 1000. The key knob is
# MCMC.effectiveSize = NULL: it turns off ergm's adaptive sample-size growth
# (those "increasing sample size" messages). The fit is rougher but fast.
ctrl <- control.ergm(MCMC.interval = 512, MCMC.samplesize = 512,
                     MCMC.effectiveSize = NULL, MCMLE.maxit = 30)

# ---- Run this: fit the mixing block, then warm-start ------------------------

# 1. Fit the mixing block to its targets.
fit_mix <- ergm(f_mix, target.stats = ts_mix, control = ctrl, eval.loglik = FALSE)

# 2. Simulate one network from that fit -> the "warm start" for the next fit.
net_warm <- simulate(fit_mix, nsim = 1)

# 3. Add an out-degree term, fitting FROM the warm start (net_warm on the LHS).
fit5 <- ergm(update(f_mix, net_warm ~ . + odegree(0)),
             target.stats = c(ts_mix, odeg_target(0)),
             control = ctrl, eval.loglik = FALSE)
summary(fit5)

# ---- Your turn: add odegree(0:1) the same way -------------------------------
# Warm-start again from fit5, then add odegree(0:1) (targets for degrees 0 and 1).
# TODO: net_warm2 <- simulate(fit5, nsim = 1)
# TODO: fit6 <- ergm(update(f_mix, net_warm2 ~ . + odegree(0:1)),
#                    target.stats = c(ts_mix, odeg_target(0:1)),
#                    control = ctrl, eval.loglik = FALSE)
# summary(fit6)

# --- Try at home -------------------------------------------------------------
# a. The hard step: add BOTH idegree(0:1) + odegree(0:1). Under ergm's default
#    (MCMLE) it struggles to converge; switching the algorithm fixes it:
#      control = control.ergm(main.method = "Stochastic-Approximation")
#    (Full staged sequence + the SA switch: R/02-sequential.R.)
