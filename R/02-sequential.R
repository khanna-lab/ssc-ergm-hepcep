# Module 3: Sequential ERGM specification.
# Add terms in stages, fit to accumulated targets, simulate to warm-start the
# next step. Geographic mixing (Module 2) is folded in as nodematch("chicago").
if (!exists("net") || !"package:ergm" %in% search()) source(here::here("R", "00-setup.R"))

# Mixing block (dyad-independent). Term order must match ts_mix.
f_mix <- net ~ edges +
  nodemix("sex",      levels2 = -1) +
  nodemix("young",    levels2 = -1) +
  nodemix("race.num", levels2 = -1) +
  nodematch("chicago")

# dnf digression (real pipeline, placement TBD): replace nodematch("chicago") with
#   dnf(by = "chicago", thresholds = c(2, 2))    # needs ergm.userterms.hepcep
#   target.stats: edges_target * c(.457, .229, .163)

# Check statistic count matches the target vector.
mix_stat_names <- names(summary(f_mix))
print(mix_stat_names)
stopifnot(length(mix_stat_names) == length(ts_mix))

# Control. Real pipeline: SA with MCMC.* = 1e6, MCMLE.maxit = 500. Scaled down
# for live fits; drop main.method for default MCMLE.
fit_control <- control.ergm(
  main.method     = "Stochastic-Approximation",
  MCMLE.maxit     = 60,
  MCMC.interval   = 1e4,
  MCMC.samplesize = 1e4
)

# Steps 1-4: mixing block (exact MLE).
fit_mix  <- ergm(f_mix, target.stats = ts_mix, eval.loglik = FALSE)
net_warm <- simulate(fit_mix, nsim = 1)

# Step 5: + odegree(0)
fit5 <- ergm(update(f_mix, net_warm ~ . + odegree(0)),
             target.stats = c(ts_mix, odeg_target(0)),
             control = fit_control, eval.loglik = FALSE)
net_warm <- simulate(fit5, nsim = 1)

# Step 6: + odegree(0:1)
fit6 <- ergm(update(f_mix, net_warm ~ . + odegree(0:1)),
             target.stats = c(ts_mix, odeg_target(0:1)),
             control = fit_control, eval.loglik = FALSE)
net_warm <- simulate(fit6, nsim = 1)

# Step 7: + idegree(0:1) + odegree(0:1)  (final model)
fit_final <- ergm(update(f_mix, net_warm ~ . + idegree(0:1) + odegree(0:1)),
                  target.stats = c(ts_mix, ideg_target(0:1), odeg_target(0:1)),
                  control = fit_control, eval.loglik = FALSE)

print(summary(fit_final))
saveRDS(fit_final, file.path(out_dir, "fit_final.rds"))
