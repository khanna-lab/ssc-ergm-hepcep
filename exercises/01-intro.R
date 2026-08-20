# =============================================================================
# Module 1 — Take-home exercise: A Brief Introduction to ERGMs
# Take-home exercises
# To be run at home 
# =============================================================================

library(statnet)

data("faux.magnolia.high")
fmh <- faux.magnolia.high

# 1. Describe the network -----------------------------------------------------
c(students = network.size(fmh), ties = network.edgecount(fmh))
mixingmatrix(fmh, "Sex")        # who befriends whom, by sex
summary(fmh ~ degree(0:5))      # how many friends people have

# 2. Null model: ties form at random (edges only) ----------------------------
random.m <- ergm(fmh ~ edges)
plogis(coef(random.m))          # baseline tie probability (inverse-logit of coef)

# 3. Assortative model: add homophily -----------------------------------------
assort.m <- ergm(fmh ~ edges + nodematch("Grade") +
                   nodematch("Race") + nodematch("Sex"))
round(coef(assort.m), 2)        # positive = ties more likely within a group
plot(gof(assort.m, GOF = ~ degree - model))   # does it reproduce the degree dist?

# 4. Friend-of-a-friend: triadic closure via GWESP ----------------------------
# GWESP adds closure with diminishing returns (not raw triangles, which would be
# degenerate -- see Module 4). Dyad-dependent, so fit by MCMC (a bit slower).
gwesp.m <- ergm(fmh ~ edges + nodematch("Grade") + nodematch("Race") +
                  nodematch("Sex") + gwesp(0.25, fixed = TRUE))
round(coef(gwesp.m), 2)
plot(gof(gwesp.m, GOF = ~ degree - model))    # compare with the assortative GOF

# 5. Simulate from a fit and compare (the idea behind GOF) --------------------
# gof() automates this. By hand: draw networks from the fitted model, then
# compare a statistic to the observed value. (This is the seed of Module 5.)
sims    <- simulate(gwesp.m, nsim = 50)
obs_deg <- summary(fmh ~ degree(0:5))
sim_deg <- t(sapply(sims, function(s) summary(s ~ degree(0:5))))
rbind(observed = obs_deg,
      sim_mean = round(colMeans(sim_deg), 1))    # observed vs. average simulated

# Plot it: simulated spread (boxplots) with the observed counts overlaid (red).
# A reasonable fit = the red points sit inside the simulated boxes.
boxplot(sim_deg, names = 0:5, xlab = "degree", ylab = "# of nodes",
        main = "Degree GOF: observed (red) vs. simulated")
points(seq_along(obs_deg), obs_deg, col = "red", pch = 19)

# --- Experiments to try ------------------------------------------------------
# a. Change the GWESP decay: gwesp(0.5, fixed = TRUE) vs gwesp(0.1, ...).
#    How does the degree goodness-of-fit change?
# b. Drop one homophily term (e.g. remove nodematch("Race")) -- does the fit suffer?
# c. Check a different GOF dimension: gof(gwesp.m, GOF = ~ espartners - model).
