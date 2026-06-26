# Module 4: assessing failure modes. Demonstrate degeneracy (odegree(0:2)),
# then MCMC diagnostics and GOF on the converged model.
if (!exists("net") || !"package:ergm" %in% search()) source(here::here("R", "00-setup.R"))

# Converged final model from Module 3
fit_final_path <- file.path(out_dir, "fit_final.rds")
if (file.exists(fit_final_path)) {
  fit_final <- readRDS(fit_final_path)
} else {
  source(here::here("R", "02-sequential.R"))
}

# Degeneracy: odegree(0:2) collapses to near-empty / near-complete networks.
message("Fitting a deliberately degenerate model (odegree(0:2))...")
fit_degen <- tryCatch(
  fit_to_targets(paste(rhs_mix, "+ odegree(0:2)"),
                 c(ts_mix, odeg_target(0:2)), basis = net),
  error = function(e) {
    message("  ergm errored (a degeneracy signature): ", conditionMessage(e)); NULL
  }
)
if (!is.null(fit_degen)) {
  net_degen <- simulate(fit_degen, nsim = 1)
  cat(sprintf("\nDegenerate model: simulated edges = %d vs target = %.0f\n",
              network.edgecount(net_degen), targets$edges_target))
}

# MCMC diagnostics on the converged model
pdf(file.path(out_dir, "mcmc-diagnostics.pdf"))
invisible(try(mcmc.diagnostics(fit_final), silent = TRUE))
dev.off()

# Goodness of fit vs the simulated degree distributions
gof_final <- gof(fit_final, GOF = ~ idegree + odegree)
png(file.path(out_dir, "gof-final.png"), width = 1000, height = 650)
plot(gof_final)
dev.off()

cat("\nModule 4 complete: diagnostics + GOF in out/\n")
