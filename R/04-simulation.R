# Module 5: simulation as diagnostic. Simulate many networks from the fit and
# compare their statistics to the targets (the ground truth, since we never had
# a single observed network).
if (!exists("net") || !"package:ergm" %in% search()) source(here::here("R", "00-setup.R"))
suppressPackageStartupMessages(library(ggplot2))

fit_final_path <- file.path(out_dir, "fit_final.rds")
if (file.exists(fit_final_path)) {
  fit_final <- readRDS(fit_final_path)
} else {
  source(here::here("R", "02-sequential.R"))
}

# Simulate an ensemble
nsim <- 100
message("Simulating ", nsim, " networks...")
sims <- simulate(fit_final, nsim = nsim)

# Per-network statistics, and their targets (same order)
sim_stats <- t(sapply(seq_len(nsim), function(i) {
  summary(sims[[i]] ~ edges + odegree(0:1) + idegree(0:1) + nodematch("chicago"))
}))
targets_vec <- c(targets$edges_target, odeg_target(0), odeg_target(1),
                 ideg_target(0), ideg_target(1), geo_target)
names(targets_vec) <- colnames(sim_stats)

# Violin per statistic, with the target as a red line
long <- data.frame(stat  = rep(colnames(sim_stats), each = nrow(sim_stats)),
                   value = as.vector(sim_stats))
tgt  <- data.frame(stat = names(targets_vec), target = as.numeric(targets_vec))
p <- ggplot(long, aes(x = stat, y = value)) +
  geom_violin(fill = "#cdeef2", color = "#0b6e7c") +
  geom_hline(data = tgt, aes(yintercept = target), color = "red", linewidth = 0.8) +
  facet_wrap(~ stat, scales = "free") +
  labs(x = NULL, y = NULL, title = "Simulated statistics vs. targets (red line)") +
  theme_minimal()
ggsave(file.path(out_dir, "sim-vs-targets.png"), p, width = 9, height = 5, dpi = 120)

# Numeric summary
comparison <- data.frame(
  statistic = names(targets_vec),
  target    = round(as.numeric(targets_vec), 1),
  sim_mean  = round(colMeans(sim_stats), 1),
  sim_lo    = round(apply(sim_stats, 2, quantile, 0.025), 1),
  sim_hi    = round(apply(sim_stats, 2, quantile, 0.975), 1)
)
cat("\nSimulated vs. target (95% interval):\n")
print(comparison, row.names = FALSE)

saveRDS(sims, file.path(out_dir, "sims_100.rds"))
cat("\nSaved sims_100.rds and sim-vs-targets.png to out/\n")
