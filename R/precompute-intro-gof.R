# Module 1 (intro) — GOF + render-bundle step. Reads the saved fits, computes
# the degree goodness-of-fit for each model, and assembles everything the slides
# read. Fast to re-run (no re-fitting) when tweaking GOF seeds or figures.
#
# Run after R/precompute-intro-fit.R:
#   Rscript R/precompute-intro-gof.R
#
# Outputs (committed, read by modules/01-ergm-intro.qmd):
#   modules/precomputed/intro.rds        summaries, coefficients, degree GOF objects
#   modules/precomputed/netplot.png      friendship network, colored by grade
#   modules/precomputed/obs-vs-sim.png   observed vs. simulated (assortative model)

suppressPackageStartupMessages(library(statnet))
library(here)

fits <- readRDS(here("out", "intro-fits.rds"))
random.m <- fits$random
assort.m <- fits$assort
gwesp.m  <- fits$gwesp

data("faux.magnolia.high")
fmh <- faux.magnolia.high

pre_dir <- here("modules", "precomputed")
dir.create(pre_dir, showWarnings = FALSE, recursive = TRUE)

res <- list()

## --- Descriptive summaries (deterministic) --------------------------------
res$size      <- c(students = network.size(fmh), ties = network.edgecount(fmh))
res$grade_tab <- table(fmh %v% "Grade")
res$sex_tab   <- table(fmh %v% "Sex")
res$sex_mix   <- mixingmatrix(fmh, "Sex")
res$degree    <- summary(fmh ~ degree(0:5))
res$targets   <- summary(fmh ~ edges + nodematch("Grade") +
                           nodematch("Race") + nodematch("Sex"))

## --- Coefficients (from the saved fits) -----------------------------------
res$null_prob   <- plogis(coef(random.m))
res$assort_coef <- round(coef(assort.m), 2)
res$gwesp_coef  <- round(coef(gwesp.m), 2)

## --- Goodness of fit on degree (the GOF code; seed-fixed) ------------------
## Two gotchas in current ergm (4.6):
##  1. `gof(fit ~ degree)` shorthand no longer restricts to degree.
##  2. `GOF = ~ degree` silently APPENDS a "model" term (the docs: "By default a
##     'model' term is added to the formula"), giving the edges/nodematch panel.
## `GOF = ~ degree - model` gives the single degree-distribution panel (the PDF).
set.seed(100); res$gof_null   <- gof(random.m, GOF = ~ degree - model)
set.seed(101); res$gof_assort <- gof(assort.m, GOF = ~ degree - model)
set.seed(102); res$gof_gwesp  <- gof(gwesp.m,  GOF = ~ degree - model)

saveRDS(res, file.path(pre_dir, "intro.rds"))
message("Saved: modules/precomputed/intro.rds")

## --- Network figures (PNG; embedded as images) ----------------------------
grade <- as.factor(fmh %v% "Grade")
pal   <- hcl.colors(nlevels(grade), "Dark 3")

png(file.path(pre_dir, "netplot.png"), width = 1600, height = 1000, res = 150)
set.seed(42)
par(mar = c(0, 0, 0, 0))
plot(fmh, vertex.col = pal[grade], vertex.border = pal[grade],
     vertex.cex = 0.7, edge.col = "#b9c6cc55")
legend("topleft", legend = levels(grade), col = pal, pch = 19,
       bty = "n", cex = 0.9, title = "Grade")
dev.off()
message("Saved: modules/precomputed/netplot.png")

png(file.path(pre_dir, "obs-vs-sim.png"), width = 1900, height = 950, res = 150)
set.seed(7)
sim <- simulate(assort.m, nsim = 1)
op <- par(mfrow = c(1, 2), mar = c(0, 0, 2, 0))
plot(fmh, vertex.col = pal[grade], vertex.border = pal[grade],
     vertex.cex = 0.6, edge.col = "#b9c6cc55", main = "Observed")
plot(sim, vertex.col = pal[grade], vertex.border = pal[grade],
     vertex.cex = 0.6, edge.col = "#b9c6cc55", main = "Simulated")
par(op)
dev.off()
message("Saved: modules/precomputed/obs-vs-sim.png")

message("Done. Module 1 renders from modules/precomputed/.")
