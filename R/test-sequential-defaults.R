# Test: does the sequential model fit with ergm 4.x DEFAULTS at n=1000?
# Same staged, warm-started fit as 02-sequential.R but with NO control overrides
# (no Stochastic-Approximation, no Hotelling). If this converges, the heavy
# overrides are a scale issue, not needed here. See R/control-settings.md.
if (!exists("net") || !"package:ergm" %in% search()) source(here::here("R", "00-setup.R"))

f_mix <- net ~ edges +
  nodemix("sex",      levels2 = -1) +
  nodemix("young",    levels2 = -1) +
  nodemix("race.num", levels2 = -1) +
  nodematch("chicago")

# Staged fit, warm-started, defaults throughout (no control = argument).
message("Mixing block...")
fit_mix  <- ergm(f_mix, target.stats = ts_mix, eval.loglik = FALSE)
net_warm <- simulate(fit_mix, nsim = 1)

message("+ odegree(0:1)...")
fit6 <- ergm(update(f_mix, net_warm ~ . + odegree(0:1)),
             target.stats = c(ts_mix, odeg_target(0:1)), eval.loglik = FALSE)
net_warm <- simulate(fit6, nsim = 1)

message("+ idegree(0:1) + odegree(0:1) (final)...")
fit_default <- ergm(update(f_mix, net_warm ~ . + idegree(0:1) + odegree(0:1)),
                    target.stats = c(ts_mix, ideg_target(0:1), odeg_target(0:1)),
                    eval.loglik = FALSE)

print(summary(fit_default))

# Convergence check: simulate from the fit and compare means to targets.
sims <- simulate(fit_default, nsim = 50)
sim_means <- colMeans(t(sapply(seq_along(sims), function(i)
  summary(sims[[i]] ~ edges + idegree(0:1) + odegree(0:1) + nodematch("chicago")))))
cat("\nSimulated mean vs target:\n")
print(round(rbind(
  sim    = sim_means,
  target = c(targets$edges_target, ideg_target(0:1), odeg_target(0:1), geo_target)
), 1))

png(file.path(out_dir, "gof-defaults.png"), width = 1000, height = 650)
plot(gof(fit_default, GOF = ~ idegree + odegree))
dev.off()

saveRDS(fit_default, file.path(out_dir, "fit_default.rds"))
cat("\nSaved fit_default.rds and gof-defaults.png to out/\n")
