# ============================================================================
# Run the full workshop ERGM pipeline end-to-end on the n=1000 synthetic data.
# ============================================================================
# Each module script sources 00-setup.R if needed, so they also run standalone.
# Outputs (fits, simulations, figures) land in out/.

library(here)

steps <- c(
  "00-setup.R",
  "01-targets.R",
  "02-sequential.R",
  "04-failure-modes.R",
  "05a-simulation.R",
  "05b-export-abm.R"
)

for (s in steps) {
  message("\n==== ", s, " ====")
  source(here("R", s))
}

message("\nPipeline complete. See out/ for fits, simulations, and figures.")
