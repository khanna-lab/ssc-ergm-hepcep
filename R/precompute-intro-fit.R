# Module 1 (intro) — FITTING step (the slow part; GWESP is MCMC).
# Fits the three models once and saves them. The GOF step reads these back,
# so goodness-of-fit can be re-run without re-fitting.
#
# Run once (re-run only if a model spec changes):
#   Rscript R/precompute-intro-fit.R      # then: Rscript R/precompute-intro-gof.R
#
# Output (intermediate, gitignored under /out/):
#   out/intro-fits.rds   the three fitted ergm objects

suppressPackageStartupMessages(library(statnet))
library(here)

data("faux.magnolia.high")
fmh <- faux.magnolia.high

message("Fitting null model ...")
random.m <- ergm(fmh ~ edges)

message("Fitting assortative model ...")
assort.m <- ergm(fmh ~ edges + nodematch("Grade") +
                   nodematch("Race") + nodematch("Sex"))

message("Fitting GWESP model (MCMC — the slow step) ...")
set.seed(42)
gwesp.m <- ergm(fmh ~ edges + nodematch("Grade") +
                  nodematch("Race") + nodematch("Sex") +
                  gwesp(0.25, fixed = TRUE))

out_dir <- here("out")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
saveRDS(list(random = random.m, assort = assort.m, gwesp = gwesp.m),
        file.path(out_dir, "intro-fits.rds"))
message("Saved fits: out/intro-fits.rds  —  now run R/precompute-intro-gof.R")
