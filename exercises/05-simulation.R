# =============================================================================
# Module 5 — Exercise: simulation as diagnostic
# Live concept: simulate an ensemble and check whether a target lands inside
# the simulated spread.
# Solution keys: R/05a-simulation.R, R/05b-export-abm.R
# =============================================================================

source(here::here("R", "00-setup.R"))

# The mixing block (same as Module 3).
f_mix <- net ~ edges +
  nodemix("sex",      levels2 = -1) +
  nodemix("young",    levels2 = -1) +
  nodemix("race.num", levels2 = -1) +
  nodematch("chicago")

# Degree terms need Stochastic-Approximation at n = 1000 (MCMLE defaults stall).
# Sampling level matters HERE too: too-low MCMC leaves consecutive draws
# autocorrelated, so the simulated intervals below come out misleadingly narrow.
# 4096 gives honest intervals in seconds. (See R/02-sequential.R.)
sa_control <- control.ergm(main.method = "Stochastic-Approximation",
                           MCMC.interval = 4096, MCMC.samplesize = 4096)

# A fitted model to simulate from (mixing block + out-degree; fits in seconds).
fit <- ergm(update(f_mix, ~ . + odegree(0:1)),
            target.stats = c(ts_mix, odeg_target(0:1)),
            control = sa_control, eval.loglik = FALSE)

# ---- Run this: simulate an ensemble, check ONE statistic --------------------
sims <- simulate(fit, nsim = 100)

# Count out-degree-0 nodes in each of the 100 simulated networks:
sim_odeg0    <- sapply(seq_along(sims), function(i) summary(sims[[i]] ~ odegree(0)))
target_odeg0 <- odeg_target(0)

# Is the target inside the middle 95% of the simulated distribution?
quantile(sim_odeg0, c(.025, .975))
target_odeg0
target_odeg0 >= quantile(sim_odeg0, .025) & target_odeg0 <= quantile(sim_odeg0, .975)

# ---- Your turn: check a different statistic ---------------------------------
# Repeat for out-degree-1. Is ITS target, odeg_target(1), inside the spread?
# TODO: sim_odeg1 <- sapply(seq_along(sims), function(i) summary(sims[[i]] ~ odegree(1)))
# TODO: quantile(sim_odeg1, c(.025, .975)); odeg_target(1)

# --- Try at home -------------------------------------------------------------
# a. Violin plot of every statistic vs. its target: R/05a-simulation.R.
# b. Export a simulated network for an ABM (edgelist + vertex table):
#    R/05b-export-abm.R.
