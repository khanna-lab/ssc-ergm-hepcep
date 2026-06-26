# Shared setup: load packages, the n=1000 nodes and targets, build the network.
# Sourced by every module and by run-all.R; safe to source repeatedly.
# Simplified from hepcep/net-ergm-v4plus (n=1000, light controls, geography via
# nodematch("chicago") folded into 02-sequential.R).

suppressPackageStartupMessages({
  library(here); library(readr); library(dplyr)
  library(network); library(ergm)
})
set.seed(20260101)

data_dir <- here("data", "synthetic")
out_dir  <- here("out")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

# Inputs from R/generate-synthetic-data.R
nodes_path   <- file.path(data_dir, "nodes.csv")
targets_path <- file.path(data_dir, "targets.rds")
if (!file.exists(nodes_path) || !file.exists(targets_path)) {
  stop("Missing data/synthetic/. Run R/generate-synthetic-data.R first.")
}
nodes   <- read_csv(nodes_path, show_col_types = FALSE)
targets <- readRDS(targets_path)

# Base directed network with node attributes
net <- network.initialize(nrow(nodes), directed = TRUE)
for (col in names(nodes)) net %v% col <- nodes[[col]]

# Geographic target: stand-in for the dnf term, expected within-area ties under
# an assumed mixing fraction.
p_within_chicago <- 0.70
geo_target <- targets$edges_target * p_within_chicago

# Degree-target helpers (counts of nodes at given degrees).
odeg_target <- function(k) with(targets$outdegree_data, mean_n[out_degree %in% k])
ideg_target <- function(k) with(targets$indegree_data,  mean_n[in_degree  %in% k])

# Mixing block + targets. unname() keeps target.stats positional (target_race_num
# carries names ergm would otherwise reject).
rhs_mix <- paste(
  "edges",
  "nodemix('sex', levels2 = -1)",
  "nodemix('young', levels2 = -1)",
  "nodemix('race.num', levels2 = -1)",
  "nodematch('chicago')",
  sep = " + "
)
ts_mix <- unname(c(
  targets$edges_target,
  targets$sex_mixing_align_order,
  targets$age_mixing_align_order,
  targets$target_race_num,
  geo_target
))

# Light controls + fitting helper (used by 03-failure-modes.R).
ctrl <- control.ergm(MCMC.interval = 1024, MCMC.samplesize = 1024, MCMLE.maxit = 60)
fit_to_targets <- function(rhs, target.stats, basis = net, control = ctrl) {
  ergm(as.formula(paste("basis ~", rhs)), target.stats = target.stats,
       control = control, eval.loglik = FALSE)
}

cat(sprintf("Setup: %d nodes, %d targets, edges_target = %.1f\n",
            network.size(net), length(targets), targets$edges_target))
