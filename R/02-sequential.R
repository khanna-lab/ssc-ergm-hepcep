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

# Every degree-term step (5-7) needs Stochastic-Approximation, not just step 7.
# Under ergm's MCMLE defaults, step 5 (+ odegree(0)) does NOT converge at n=1000: the
# estimating equations stop approaching the tolerance region, ergm keeps enlarging the
# MCMC sample, and each iteration costs more than the last (measured: >2 hours at 99%
# CPU, still on MCMLE iteration 7, no convergence). Under SA the whole 5-7 chain fits
# in ~9 seconds.
#
# Sampling level then matters. Under SA the sampler is governed by the SA.* family, and
# SA.interval/SA.samplesize DEFAULT to MCMC.interval/MCMC.samplesize -- so those DO tune
# the SA chain. At n=1000, measured over the full 5-7 chain, scoring how many of the six
# targets land inside the 95% interval of 20 simulated networks:
#   SA defaults      0.05 min   3/6      <- fast but biased: too sparse, too many isolates
#   + 1024/1024      0.05 min   2/6
#   + 4096/4096      0.15 min   6/6      <- chosen
#   + 16384/16384    0.55 min   6/6      <- no gain over 4096
# Low interval also makes the Module 5 diagnostic look better than it is: consecutive
# draws stay autocorrelated, so the simulated intervals come out misleadingly narrow.
#
# NOTE: at full scale the termination criterion CAN matter too -- the research pipeline
# needed Hotelling to complete a fit that stalled under Hummel (the final MCMLE/Newton-
# Raphson step is termination-governed even under SA).
sa_control <- control.ergm(main.method = "Stochastic-Approximation",
                           MCMC.interval = 4096, MCMC.samplesize = 4096)

# Steps 1-4: mixing block. Dyad-independent, so it fits easily -- but targets are
# non-integer (e.g. edges_target = 711.1), so ergm matches them in expectation via
# MCMC (SAN -> MPLE -> MCMLE), not by closed-form MLE.
fit_mix  <- ergm(f_mix, target.stats = ts_mix, eval.loglik = FALSE)
net_warm <- simulate(fit_mix, nsim = 1)

# Step 5: + odegree(0)   (needs SA -- stalls indefinitely under MCMLE defaults)
fit5 <- ergm(update(f_mix, net_warm ~ . + odegree(0)),
             target.stats = c(ts_mix, odeg_target(0)),
             control = sa_control, eval.loglik = FALSE)
net_warm <- simulate(fit5, nsim = 1)

# Step 6: + odegree(0:1)   (SA)
fit6 <- ergm(update(f_mix, net_warm ~ . + odegree(0:1)),
             target.stats = c(ts_mix, odeg_target(0:1)),
             control = sa_control, eval.loglik = FALSE)
net_warm <- simulate(fit6, nsim = 1)

# Step 7: + idegree(0:1) + odegree(0:1)  (final model — needs SA)
fit_final <- ergm(update(f_mix, net_warm ~ . + idegree(0:1) + odegree(0:1)),
                  target.stats = c(ts_mix, ideg_target(0:1), odeg_target(0:1)),
                  control = sa_control, eval.loglik = FALSE)

print(summary(fit_final))
saveRDS(fit_final, file.path(out_dir, "fit_final.rds"))
