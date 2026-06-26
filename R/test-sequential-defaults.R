# Test: does the sequential model fit with ergm 4.x DEFAULTS at n=1000, and does
# the full-pipeline override recipe do better on the hard final model?
# Convergence is judged by a SECOND simulation vs targets, not the fit's own
# diagnostics. See R/control-settings.md.
if (!exists("net") || !"package:ergm" %in% search()) source(here::here("R", "00-setup.R"))

f_mix <- net ~ edges +
  nodemix("sex",      levels2 = -1) +
  nodemix("young",    levels2 = -1) +
  nodemix("race.num", levels2 = -1) +
  nodematch("chicago")

# Staged warm-start with DEFAULTS (no control overrides).
message("Mixing block...")
fit_mix  <- ergm(f_mix, target.stats = ts_mix, eval.loglik = FALSE)
net_warm <- simulate(fit_mix, nsim = 1)

message("+ odegree(0:1)...")
fit6 <- ergm(update(f_mix, net_warm ~ . + odegree(0:1)),
             target.stats = c(ts_mix, odeg_target(0:1)), eval.loglik = FALSE)
net_warm <- simulate(fit6, nsim = 1)

# Final model: the hard one (in- AND out-degree). Fit two ways for comparison.
f_final  <- update(f_mix, net_warm ~ . + idegree(0:1) + odegree(0:1))
ts_final <- c(ts_mix, ideg_target(0:1), odeg_target(0:1))

# (A) ergm 4.x defaults
message("Final model (A): defaults...")
fit_default <- ergm(f_final, target.stats = ts_final, eval.loglik = FALSE)

# (B) full-pipeline override recipe: SA + Hotelling + fixed thinning
message("Final model (B): override recipe (SA + Hotelling)...")
fit_override <- ergm(
  f_final, target.stats = ts_final, eval.loglik = FALSE,
  control = control.ergm(
    main.method        = "Stochastic-Approximation",
    MCMLE.termination  = "Hotelling",
    MCMC.effectiveSize = NULL
  )
)

# Compare: simulate from each fit and check means against the targets.
sim_means <- function(fit, n = 50) {
  s <- simulate(fit, nsim = n)
  colMeans(t(sapply(seq_len(n), function(i)
    summary(s[[i]] ~ edges + idegree(0:1) + odegree(0:1) + nodematch("chicago")))))
}
cat("\nSimulated mean vs target (final model):\n")
print(round(rbind(
  target   = c(targets$edges_target, ideg_target(0:1), odeg_target(0:1), geo_target),
  defaults = sim_means(fit_default),
  override = sim_means(fit_override)
), 1))

saveRDS(fit_default,  file.path(out_dir, "fit_default.rds"))
saveRDS(fit_override, file.path(out_dir, "fit_override.rds"))
cat("\nSaved fit_default.rds and fit_override.rds to out/\n")
