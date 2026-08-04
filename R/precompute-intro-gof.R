# Module 1 (intro) — GOF + render-bundle step. Reads the saved fits and writes
# EVERYTHING the slides display: numeric outputs as text snippets and all plots as
# PNGs. The .qmd then renders with zero R execution — it only reads these files.
#
# Run after R/precompute-intro-fit.R:
#   Rscript R/precompute-intro-gof.R
#
# Outputs (committed, read by modules/01-ergm-intro.qmd):
#   modules/precomputed/out-*.md    numeric summaries as fenced text (searchable)
#   modules/precomputed/*.png       network plots + degree GOF plots

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

## Capture a printed R object as a fenced code block the .qmd can `include`.
write_out <- function(x, name) {
  txt <- capture.output(print(x))
  writeLines(c("```", txt, "```"), file.path(pre_dir, paste0(name, ".md")))
  message("Saved: modules/precomputed/", name, ".md")
}

## --- Descriptive summaries (deterministic) --------------------------------
write_out(c(students = network.size(fmh), ties = network.edgecount(fmh)), "out-size")
write_out(table(fmh %v% "Grade"), "out-grade")
write_out(table(fmh %v% "Sex"),   "out-sex")
write_out(mixingmatrix(fmh, "Sex"), "out-mixing")
write_out(summary(fmh ~ degree(0:5)), "out-degree")
write_out(summary(fmh ~ edges + nodematch("Grade") +
                    nodematch("Race") + nodematch("Sex")), "out-targets")

## --- Coefficients (from the saved fits) -----------------------------------
write_out(plogis(coef(random.m)), "out-null")
write_out(round(coef(assort.m), 2), "out-assort")
write_out(round(coef(gwesp.m), 2),  "out-gwesp")

## --- Goodness of fit on degree, rendered straight to PNG ------------------
## `GOF = ~ degree - model`: degree only. `- model` suppresses the model-stats
## panel that current ergm (4.6) otherwise appends.
gof_png <- function(fit, name, seed) {
  set.seed(seed)
  g <- gof(fit, GOF = ~ degree - model)
  png(file.path(pre_dir, name), width = 1600, height = 980, res = 150)
  plot(g)
  dev.off()
  message("Saved: modules/precomputed/", name)
}
gof_png(random.m, "gof-null.png",   100)
gof_png(assort.m, "gof-assort.png", 101)
gof_png(gwesp.m,  "gof-gwesp.png",  102)

## --- Network figures ------------------------------------------------------
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

message("Done. Module 1 now renders with no R execution — pure includes + images.")
