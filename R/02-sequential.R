# ============================================================================
# Sequential ERGM specification (presentation Module 3)
# ============================================================================
# Build the model in stages. Each step adds a term, fits to the accumulated
# target stats, then simulates one network to warm-start the next step (as the
# full pipeline does). Term order in the formula must match target.stats order.
#
# Geographic mixing (presentation Module 2) is folded in here as the
# nodematch("chicago") stage of the mixing block, since in the real pipeline the
# geographic term is just one stage of the staged fit -- not a separate step.
#
# DNF DIGRESSION (placement TBD): the full pipeline uses a custom distance
# near/far term instead of nodematch("chicago"). To swap it in, once
# ergm.userterms.hepcep is installed:
#   library(ergm.userterms.hepcep)
#   ... + dnf(by = "chicago", thresholds = c(2, 2))
#   target.stats for it: edges_target * c(.457, .229, .163)
# nodes.csv carries lon/lat, so the real term is feasible data-wise.
#
# This module calls ergm() directly (rather than a wrapper) so the formula,
# target.stats, and control settings are all visible at each step.
# ============================================================================
if (!exists("net") || !"package:ergm" %in% search()) source(here::here("R", "00-setup.R"))

# Mixing block as an explicit formula; geographic nodematch folded in.
# (ts_mix, odeg_target(), ideg_target() are the target objects from 00-setup.R.)
f_mix <- net ~ edges +
  nodemix("sex",      levels2 = -1) +
  nodemix("young",    levels2 = -1) +
  nodemix("race.num", levels2 = -1) +
  nodematch("chicago")

# Verify the statistic order matches the target vector (names/order only; the
# values are 0 on the empty base network). A length mismatch means a
# nodemix(levels2 = -1) target vector is misaligned.
mix_stat_names <- names(summary(f_mix))
cat("Mixing-block terms (", length(mix_stat_names), "):\n", sep = "")
print(mix_stat_names)
stopifnot(length(mix_stat_names) == length(ts_mix))

# --- Fitting control (visible) ----------------------------------------------
# The degree terms make the model dyad-dependent, so those steps use MCMC. The
# full pipeline uses Stochastic-Approximation with heavy settings (real values
# in comments); scaled down here so n=1000 fits converge live. If SA struggles
# on the workshop data, drop main.method to fall back to ergm's default MCMLE.
fit_control <- control.ergm(
  main.method     = "Stochastic-Approximation",  # real workflow: same
  MCMLE.maxit     = 60,     # real: 500
  MCMC.interval   = 1e4,    # real: 1e6
  MCMC.samplesize = 1e4     # real: 1e6
)

# --- Steps 1-4: mixing block (dyad-independent -> exact MLE, no MCMC) --------
# The real pipeline runs SA here too; for dyad-independent terms MLE is exact
# and far faster, so we use it and then simulate a network to warm-start.
message("Steps 1-4: mixing block (MLE)")
fit_mix  <- ergm(f_mix, target.stats = ts_mix, eval.loglik = FALSE)
net_warm <- simulate(fit_mix, nsim = 1)

# --- Step 5: + odegree(0)  (proportion of isolates) -------------------------
message("Step 5: + odegree(0)")
fit5 <- ergm(
  update(f_mix, net_warm ~ . + odegree(0)),
  target.stats = c(ts_mix, odeg_target(0)),
  control      = fit_control,
  eval.loglik  = FALSE
)
net_warm <- simulate(fit5, nsim = 1)

# --- Step 6: + odegree(0:1) -------------------------------------------------
message("Step 6: + odegree(0:1)")
fit6 <- ergm(
  update(f_mix, net_warm ~ . + odegree(0:1)),
  target.stats = c(ts_mix, odeg_target(0:1)),
  control      = fit_control,
  eval.loglik  = FALSE
)
net_warm <- simulate(fit6, nsim = 1)

# --- Step 7: + idegree(0:1) + odegree(0:1)  [final model] -------------------
message("Step 7: + idegree(0:1) + odegree(0:1)  [final]")
fit_final <- ergm(
  update(f_mix, net_warm ~ . + idegree(0:1) + odegree(0:1)),
  target.stats = c(ts_mix, ideg_target(0:1), odeg_target(0:1)),
  control      = fit_control,
  eval.loglik  = FALSE
)

cat("\nFinal model:\n")
print(summary(fit_final))

saveRDS(fit_final, file.path(out_dir, "fit_final.rds"))
cat("\nSaved fit_final.rds to out/\n")
