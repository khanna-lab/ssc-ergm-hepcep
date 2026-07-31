# Precompute ALL of Module 1's (intro) displayed output so the slides render
# from fixed, reproducible results — no live fitting, no seed drift.
#
# Run once (re-run only if a model spec or figure changes):
#   Rscript R/precompute-intro.R
#
# Outputs (committed, read by modules/01-ergm-intro.qmd):
#   modules/precomputed/intro.rds        text results + both degree GOF objects
#   modules/precomputed/netplot.png      the friendship network, colored by grade
#   modules/precomputed/obs-vs-sim.png   observed vs. simulated (assortative model)

suppressPackageStartupMessages(library(statnet))
library(here)

data("faux.magnolia.high")
fmh <- faux.magnolia.high

pre_dir <- here("modules", "precomputed")
dir.create(pre_dir, showWarnings = FALSE, recursive = TRUE)

res <- list()

## --- Descriptive summaries (deterministic) --------------------------------
res$size      <- c(students = network.size(fmh),
                   ties     = network.edgecount(fmh))
res$grade_tab <- table(fmh %v% "Grade")
res$sex_tab   <- table(fmh %v% "Sex")
res$sex_mix   <- mixingmatrix(fmh, "Sex")
res$degree    <- summary(fmh ~ degree(0:5))
res$targets   <- summary(fmh ~ edges + nodematch("Grade") +
                           nodematch("Race") + nodematch("Sex"))

## --- Null model -----------------------------------------------------------
random.m       <- ergm(fmh ~ edges)
res$null_prob  <- plogis(coef(random.m))

## --- Assortative mixing model (dyad-independent, deterministic) -----------
assort.m         <- ergm(fmh ~ edges + nodematch("Grade") +
                           nodematch("Race") + nodematch("Sex"))
res$assort_coef  <- round(coef(assort.m), 2)

## --- GWESP friend-of-a-friend model (MCMC; the slow step) -----------------
set.seed(42)
gwesp.m         <- ergm(fmh ~ edges + nodematch("Grade") +
                          nodematch("Race") + nodematch("Sex") +
                          gwesp(0.25, fixed = TRUE))
res$gwesp_coef  <- round(coef(gwesp.m), 2)

## --- Goodness of fit on degree (seed-sensitive → fixed) -------------------
set.seed(100); res$gof_null   <- gof(random.m ~ degree)
set.seed(101); res$gof_assort <- gof(assort.m ~ degree)
set.seed(102); res$gof_gwesp  <- gof(gwesp.m  ~ degree)

saveRDS(res, file.path(pre_dir, "intro.rds"))
message("Saved: modules/precomputed/intro.rds")

## --- Base-R network figures (saved as PNG; embedded as images) ------------
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

message("Done. Module 1 will render from these artifacts.")
