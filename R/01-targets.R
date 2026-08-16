# ============================================================================
# Module 1 -- Aggregate summaries -> target statistics
# ============================================================================
# Re-derive each ERGM target from the empirical summaries, to make the
# "summaries -> targets" step explicit. The canonical targets are computed once
# by R/generate-synthetic-data.R and saved to targets.rds; here we reproduce
# the math for teaching and confirm the two match. No ERGM is fitted in this
# module -- fitting begins in Module 3.
# ============================================================================
if (!exists("net")) source(here::here("R", "00-setup.R"))

n_workshop   <- nrow(nodes)     # 1000
n_full       <- 32002           # full synthpop size
scale_factor <- n_workshop / n_full
cat(sprintf("\nScaling empirical counts by n/%d = %.4f\n", n_full, scale_factor))

# --- 1. Edge-count target, from the in/out-degree distributions -------------
# Empirical mean number of nodes at each degree (full network), scaled to n.
indegree_data <- read.table(text = "
  in_degree num_n
  0  20666.67
  1   6499.50
  2   2657.25
  3   1169.96
  4    533.52
  5    248.32
  6    117.14
  7     55.79
  8     26.76
  9     12.90
  10     6.25
", header = TRUE)
indegree_data$num_n <- indegree_data$num_n * scale_factor

outdegree_data <- read.table(text = "
  out_degree num_n
  0  19387.20
  1   6469.30
  2   2968.26
  3   1485.72
  4    774.64
  5    413.58
  6    224.26
  7    122.94
  8     67.95
  9     37.79
  10    21.12
", header = TRUE)
outdegree_data$num_n <- outdegree_data$num_n * scale_factor

# Total edges = sum(degree * count); average the in- and out-based estimates.
inedges_target  <- sum(indegree_data$in_degree  * indegree_data$num_n)
outedges_target <- sum(outdegree_data$out_degree * outdegree_data$num_n)
edges_target    <- mean(c(inedges_target, outedges_target))
cat(sprintf("\n[edges] in=%.1f, out=%.1f -> edges_target = %.2f\n",
            inedges_target, outedges_target, edges_target))

# --- 2. Sex mixing targets (proportions x edges_target) ---------------------
# Each target = edges * (share of edges sent by a group) * (within-group fraction).
tgt.male.pctmale     <- edges_target * 0.60 * 0.55
tgt.male.pctfemale   <- edges_target * 0.60 * 0.44
tgt.female.pctmale   <- edges_target * 0.38 * 0.72
tgt.female.pctfemale <- edges_target * 0.38 * 0.28
# Order matches nodemix("sex", levels2 = -1)
sex_mixing_align_order <- c(tgt.male.pctfemale, tgt.female.pctmale, tgt.male.pctmale)
cat("\n[sex mixing] ", paste(round(sex_mixing_align_order, 1), collapse = ", "), "\n")

# --- 3. Age (young) mixing targets ------------------------------------------
tgt.young.pctold   <- edges_target * 0.16 * 0.52
tgt.old.pctyoung   <- edges_target * 0.84 * 0.10
tgt.young.pctyoung <- edges_target * 0.16 * 0.48
age_mixing_align_order <- c(tgt.young.pctold, tgt.old.pctyoung, tgt.young.pctyoung)
cat("[age mixing] ", paste(round(age_mixing_align_order, 1), collapse = ", "), "\n")

# --- 4. Race mixing targets (4x4 mixing matrix) -----------------------------
pct_to <- c(white = 0.59, black = 0.18, hispanic = 0.17, other = 0.03)
race_mix <- matrix(c(
  0.758, 0.091, 0.111, 0.040,
  0.333, 0.495, 0.161, 0.011,
  0.345, 0.011, 0.632, 0.011,
  0.638, 0.106, 0.202, 0.053
), nrow = 4, byrow = TRUE,
dimnames = list(c("Wh", "Bl", "Hi", "Ot"), c("Wh", "Bl", "Hi", "Ot")))

target_race_num <- c(
  edges_target * pct_to["black"]    * race_mix["Bl", "Wh"],
  edges_target * pct_to["hispanic"] * race_mix["Hi", "Wh"],
  edges_target * pct_to["other"]    * race_mix["Ot", "Wh"],
  edges_target * pct_to["white"]    * race_mix["Wh", "Bl"],
  edges_target * pct_to["black"]    * race_mix["Bl", "Bl"],
  edges_target * pct_to["hispanic"] * race_mix["Hi", "Bl"],
  edges_target * pct_to["other"]    * race_mix["Ot", "Bl"],
  edges_target * pct_to["white"]    * race_mix["Wh", "Hi"],
  edges_target * pct_to["black"]    * race_mix["Bl", "Hi"],
  edges_target * pct_to["hispanic"] * race_mix["Hi", "Hi"],
  edges_target * pct_to["other"]    * race_mix["Ot", "Hi"],
  edges_target * pct_to["white"]    * race_mix["Wh", "Ot"],
  edges_target * pct_to["black"]    * race_mix["Bl", "Ot"],
  edges_target * pct_to["hispanic"] * race_mix["Hi", "Ot"],
  edges_target * pct_to["other"]    * race_mix["Ot", "Ot"]
)
cat("[race mixing] 15 targets, e.g. Bl->Wh =", round(target_race_num[1], 1), "\n")

# --- Bundle and confirm against the generator's targets.rds -----------------
targets_recomputed <- list(
  edges_target           = edges_target,
  indegree_data          = indegree_data,
  outdegree_data         = outdegree_data,
  sex_mixing_align_order = sex_mixing_align_order,
  age_mixing_align_order = age_mixing_align_order,
  target_race_num        = target_race_num
)

cat("\n-- Recomputed targets --\n")
str(targets_recomputed)
print(targets_recomputed)

check <- all.equal(targets_recomputed, targets)
cat("\nMatches generator's targets.rds:", isTRUE(check), "\n")
if (!isTRUE(check)) print(check)
