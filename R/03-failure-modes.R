# Module 4: assessing failure modes.


rm(list=ls())

## Show three ways to diagnose model failure

if (!exists("net") || !"package:ergm" %in% search()) source(here::here("R", "00-setup.R"))

# Converged final model from Module 3 (fit it if we don't have it saved).
fit_final_path <- file.path(out_dir, "fit_final.rds")
if (!file.exists(fit_final_path)) source(here::here("R", "02-sequential.R"))
fit_final <- readRDS(fit_final_path)

# ---------------------------------------------------------------------------
# 1. Degeneracy — the full model specification.
#    The Module 3 mixing block with ONE new degree term added.
#    In the full n~32k pipeline, odegree(0:2) was the degenerate step
#    (fit-stepwise-ergms.R: net_fit_stepwise_dnf_odeg0_2  # this is degenerate).
#    At this n=1000 scale odegree(0:2) fits fine, so we push one range further:
#    odegree(0:3), which is degenerate here (linear dependence -> blow-up).
# ---------------------------------------------------------------------------
f_degen <- net ~ edges +
  nodemix("sex",      levels2 = -1) +
  nodemix("young",    levels2 = -1) +
  nodemix("race.num", levels2 = -1) +
  nodematch("chicago") +
  odegree(0:3)                              # <-- NEW TERM (the degenerate one)


ts_degen <- c(ts_mix, odeg_target(0:3))     # mixing targets + the new degree targets

message("Fitting the degenerate model (odegree(0:3)) ...")

fit_degen <- tryCatch(
  ergm(f_degen, target.stats = ts_degen, control = ctrl, eval.loglik = FALSE),
  error = function(e) {
    # An ergm() error here is itself a degeneracy signature, not a bug to fix.
    message("  ergm errored (a degeneracy signature): ", conditionMessage(e))
    NULL
  }
)

summary(fit_degen)

# If it did return a fit, a degenerate one simulates near-empty or near-complete
# networks — check the edge count against the target.
if (!is.null(fit_degen)) {
  net_degen <- simulate(fit_degen, nsim = 1)
  cat(sprintf("Degenerate model: simulated edges = %d  (target ~ %.0f)\n",
              network.edgecount(net_degen), targets$edges_target))
}

# ---------------------------------------------------------------------------
# 2. MCMC diagnostics on the CONVERGED model — did the sampler behave?
#    Look for flat/drifting traces and autocorrelation that doesn't decay.
# ---------------------------------------------------------------------------
pdf(file.path(out_dir, "mcmc-diagnostics.pdf"))
invisible(try(mcmc.diagnostics(fit_final), silent = TRUE))
dev.off()

# ---------------------------------------------------------------------------
# 3. Goodness of fit — does the converged model reproduce the degree targets?
#    `- model` keeps the plot to the degree panels (ergm otherwise appends a
#    model-statistics panel).
# ---------------------------------------------------------------------------
gof_final <- gof(fit_final, GOF = ~ idegree + odegree - model)
png(file.path(out_dir, "gof-final.png"), width = 1000, height = 650)
plot(gof_final)
dev.off()

cat("Module 4 complete: diagnostics + GOF written to out/\n")
