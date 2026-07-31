# Precompute the slow Module 1 (intro) fits so the slides render without
# re-fitting. The GWESP model is dyad-dependent (MCMC) and can take a while.
#
# Run once (re-run only if the model spec changes):
#   Rscript R/precompute-intro-fits.R
#
# Output (committed, read by modules/01-ergm-intro.qmd):
#   modules/precomputed/gwesp-intro.rds

suppressPackageStartupMessages(library(statnet))
library(here)

data("faux.magnolia.high")
fmh <- faux.magnolia.high

set.seed(42)  # reproducible MCMC fit + GOF

message("Fitting GWESP (friend-of-a-friend) model — the slow step ...")
gwesp.m <- ergm(fmh ~ edges +
                  nodematch("Grade") +
                  nodematch("Race") +
                  nodematch("Sex") +
                  gwesp(0.25, fixed = TRUE))

message("Computing goodness-of-fit on degree ...")
gof_degree <- gof(gwesp.m ~ degree)

loglik <- tryCatch(round(as.numeric(logLik(gwesp.m)), 0),
                   error = function(e) NA_real_)

out <- list(
  coef       = round(coef(gwesp.m), 2),   # printed on the fit slide
  loglik     = loglik,
  gof_degree = gof_degree                 # plotted on the GOF slide
)

dir.create(here("modules", "precomputed"), showWarnings = FALSE, recursive = TRUE)
saveRDS(out, here("modules", "precomputed", "gwesp-intro.rds"))
message("Saved: modules/precomputed/gwesp-intro.rds")
