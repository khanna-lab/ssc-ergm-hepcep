# =============================================================================
# Module 6 — Exercise: a custom term for geography
# Live concept: nodematch only asks whether two labels match; dnf also asks how
# far the tie went. Check both on a network small enough to verify by hand.
# Solution key: modules/06-geographic-extensions.qmd (Module 6 has no R/ script)
# =============================================================================

library(ergm)                     # attaches `network` too
library(ergm.userterms.hepcep)    # pre-installed in the Posit Cloud workspace

# Three Hyde Park landmarks, three directed ties. Nodes 1 and 2 are category 1,
# node 3 is category 2. No fitting here, so the whole exercise runs in seconds.
m <- matrix(c(1,2, 2,3, 3,1), byrow = TRUE, ncol = 2)   # 1->2, 2->3, 3->1
g <- as.network(m, matrix.type = "edgelist", directed = TRUE)

g %v% "lat"  <- c(41.796027, 41.790636, 41.768876)   # Promontory Pt, MSI, South Shore
g %v% "lon"  <- c(-87.577310, -87.582482, -87.562375)
g %v% "cat1" <- c(1, 1, 2)

# Tie distances, worked out from those coordinates:
#   1->2 = 0.73 km     2->3 = 2.92 km     3->1 = 3.24 km

# ---- Run this: what nodematch cannot see ------------------------------------
summary(g ~ nodematch("cat1"))    # 1 -- the one within-category tie, 1->2

# That 1 would be unchanged if 1->2 were 300 km long. `dnf` cross-classifies each
# tie by the SOURCE node's category and by whether the tie falls under that
# category's threshold. `base` says which of the 2n cells to omit as a reference.
summary(g ~ dnf(by = "cat1", thresholds = c(2, 2), base = 4))
#> dnf.cat1.1.n dnf.cat1.1.f dnf.cat1.2.n
#>            1            1            0

summary(g ~ dnf(by = "cat1", thresholds = c(2, 2), base = 1))
#> dnf.cat1.1.f dnf.cat1.2.n dnf.cat1.2.f
#>            1            0            1

# Reading both calls: 1.n = 1, 1.f = 1, 2.n = 0, 2.f = 1. Only 1->2 beat the 2 km
# threshold. The four cells sum to 3, the edge count -- every tie lands in exactly
# one cell. That sum check is the cheapest correctness test for a term like this.
network.edgecount(g)

# ---- Your turn: move one threshold ------------------------------------------
# Tighten category 1 to 0.1 km and leave category 2 at 2 km. PREDICT which cells
# change before you run it: with a 0.1 km cutoff, is 1->2 still "near"?
# TODO: summary(g ~ dnf(by = "cat1", thresholds = c(0.1, 2), base = 4))
# TODO: summary(g ~ dnf(by = "cat1", thresholds = c(0.1, 2), base = 1))
# Do the four cells still sum to 3?

# --- Try at home -------------------------------------------------------------
# a. Swap the stand-in for the real term on the n = 1000 network and count
#    statistics. Run source(here::here("R", "00-setup.R")) first, then compare
#    the mixing block ending in nodematch("chicago")               -> 23 stats
#    against one ending in dnf(by = "chicago", thresholds = c(2, 2)) -> 25 stats.
# b. Refit that mixing block with the four near/far targets (.457, .229, .163,
#    .151 of edges_target, from the survey summaries). Does it still converge?
# c. The sibling term: summary(g ~ dist(1:3)) bands ties by distance and ignores
#    category entirely. Which question does each term answer that the other can't?
