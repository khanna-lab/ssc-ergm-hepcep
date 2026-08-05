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

fit_mix  <- ergm(f_mix, target.stats = ts_mix, 
              eval.loglik = FALSE)
net_warm <- simulate(fit_mix, nsim = 1)                 # warm start (Module 3 idea)

fit_mix_sa  <- ergm(f_mix, 
      target.stats = ts_mix, 
      control = control.ergm(main.method = "Stochastic-Approximation"),
      eval.loglik = FALSE
      )

net_warm_sa <- simulate(fit_mix_sa, nsim = 1)                 # warm start (Module 3 idea)

net_warm    
net_warm_sa

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
# fit_mcmle <- ergm(f_hard, target.stats = ts_hard, eval.loglik = FALSE,
#                   verbose = TRUE,                      # <- prints every iteration
#                   control = control.ergm(
#                     main.method     = "MCMLE",
#                     MCMLE.maxit     = 60,
#                     MCMC.interval   = 1e4,
#                     MCMC.samplesize = 1e4)) # seems to hang

set.seed(1) 
fit_sa <- ergm(f_hard, target.stats = ts_hard, eval.loglik = FALSE,
               verbose = TRUE,
               control = control.ergm(
                 main.method     = "Stochastic-Approximation",
                 MCMLE.maxit     = 60,
                 MCMC.interval   = 1e4,
                 MCMC.samplesize = 1e4)) #fits quickly, but the MCMC/MCLE are not used under SA
fit_sa
sim_sa_hard <- simulate(fit_sa, nsim=1)
sim_sa_hard

set.seed(1)
fit_sa_2 <- ergm(f_hard, target.stats = ts_hard, eval.loglik = FALSE,
               verbose = TRUE,
               control = control.ergm(
                 main.method     = "Stochastic-Approximation")
)
sim_sa_2 <- simulate(fit_sa_2)
sim_sa_2

