# =============================================================================
# Module 3 — Exercise: sequential fitting with warm starts
# Live concept: fit a block, SIMULATE it, and use that network to warm-start
# the next, harder fit.
# Solution key: R/02-sequential.R
# =============================================================================

# Loads net, ts_mix, rhs_mix, odeg_target(), and the fit_to_targets() helper.
source(here::here("R", "00-setup.R"))

# ---- Run this: fit the mixing block, then warm-start ------------------------
# (Fits take a few seconds each at n = 1000.)

# 1. Fit the dyad-independent mixing block.
fit_mix <- fit_to_targets(rhs_mix, ts_mix)

# 2. Simulate one network from that fit -> the "warm start" for the next fit.
net_warm <- simulate(fit_mix, nsim = 1)

# 3. Add an out-degree term, fitting FROM the warm start (basis = net_warm).
fit5 <- fit_to_targets(paste(rhs_mix, "+ odegree(0)"),
                       c(ts_mix, odeg_target(0)),
                       basis = net_warm)
summary(fit5)

# ---- Your turn: add odegree(0:1) the same way -------------------------------
# Warm-start again from fit5, then add odegree(0:1) (two targets: degrees 0 and 1).
# TODO: net_warm2 <- simulate(fit5, nsim = 1)
# TODO: fit6 <- fit_to_targets(paste(rhs_mix, "+ odegree(0:1)"),
#                              c(ts_mix, odeg_target(0:1)),
#                              basis = net_warm2)
# summary(fit6)

# --- Try at home -------------------------------------------------------------
# a. The hard step: add BOTH idegree(0:1) + odegree(0:1). Under ergm's default
#    (MCMLE) it struggles to converge; switching the algorithm fixes it:
#      control = control.ergm(main.method = "Stochastic-Approximation")
#    (Full staged sequence + the SA switch: R/02-sequential.R.)
