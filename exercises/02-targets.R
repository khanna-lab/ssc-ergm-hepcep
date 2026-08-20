# =============================================================================
# Module 2 — Exercise: from aggregate summaries to network targets
# Live concept: turn a degree distribution into an edge count.
# Solution key: R/01-targets.R
# =============================================================================

# Loads the synthetic data + the `targets` list (prints a short setup line).
source(here::here("R", "00-setup.R"))

# ---- Run this: in-edges from the in-degree distribution ---------------------
# indegree_data has one row per degree: `in_degree`, and `num_n` = # people
# reporting that in-degree.
indeg <- targets$indegree_data
indeg

# Every tie is one partner-slot for someone, so:
#   total in-edges = sum( degree * # people at that degree )
inedges_target <- sum(indeg$in_degree * indeg$num_n)
inedges_target                      # ~ 630.8

# ---- Your turn: repeat for out-degree, then reconcile -----------------------
outdeg <- targets$outdegree_data

# TODO: mirror the in-edges line above, for the OUT-degree distribution.
# outedges_target <- sum(outdeg$________ * outdeg$________)

# In- and out-edges count the SAME ties, so they should agree; they don't
# exactly (each is estimated separately), so we average them into one target.
# TODO: edges_target <- mean(c(inedges_target, outedges_target))    # ~ 711
# edges_target

# --- Try at home -------------------------------------------------------------
# a. Turn mixing PROPORTIONS into counts. A sex-mixing cell is, e.g.,
#      edges_target * male_share * male_within
#    Then match the cell ORDER to summary(net ~ nodemix("sex", levels2 = -1)).
# b. See how R/01-targets.R assembles the full target vector
#      c(edges_target, sex_target, age_target, race_target)
#    and length-checks it against the number of ERGM terms.
