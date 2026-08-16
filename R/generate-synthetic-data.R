# Generate workshop dataset
#
# Samples n=1000 nodes from the HepCEP synthetic population and computes
# the target statistics used in the ERGM fitting modules.
#
# Inputs:  data/full/synthpop-2023-10-12 12_01_32.csv  (full 32k-node synthpop,
#          from hepcep/net-ergm-v4plus; filename kept for provenance)
# Outputs: data/synthetic/nodes.csv
#          data/synthetic/targets.rds

rm(list = ls())

library(dplyr)
library(readr)
library(here)

set.seed(20260101)  # reproducible draw

# --- Parameters ---

n_workshop <- 1000

# --- Load full synthpop ---
# Sourced from hepcep/net-ergm-v4plus; the dated filename is kept for provenance.
synthpop_path <- here("data", "full", "synthpop-2023-10-12 12_01_32.csv")
if (!file.exists(synthpop_path)) {
  stop("synthpop file not found in data/full/. See data/full/README.md.")
}

full_pop <- read_csv(synthpop_path, show_col_types = FALSE)
cat("Full population:", nrow(full_pop), "nodes\n")

# --- Sample ---

nodes <- full_pop |>
  slice_sample(n = n_workshop) |>
  mutate(id = row_number()) |>
  select(id, sex, race, age, zipcode, lon, lat) |>
  mutate(
    young    = as.integer(age < 26),
    race.num = recode(race, Wh = 1L, Bl = 2L, Hi = 3L, Ot = 4L),  # dotted name matches nodemix("race.num") in the modules
    chicago  = if_else(substr(as.character(zipcode), 1, 3) == "606", 1L, 2L)
  )

cat("Workshop sample:", nrow(nodes), "nodes\n")
cat("Sex distribution:\n");  print(table(nodes$sex))
cat("Race distribution:\n"); print(table(nodes$race))
cat("Young (age < 26):", mean(nodes$young), "\n")
cat("Chicago area:", mean(nodes$chicago == 1), "\n")

# --- Compute target statistics ---
# Mixing proportions are fixed from the meta-analysis (process-data.R).
# Edge counts scale proportionally to n_workshop / 32002.

scale_factor <- n_workshop / 32002

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
", header = TRUE) |>
  mutate(num_n = num_n * scale_factor)

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
", header = TRUE) |>
  mutate(num_n = num_n * scale_factor)

inedges_target  <- sum(indegree_data$in_degree  * indegree_data$num_n)
outedges_target <- sum(outdegree_data$out_degree * outdegree_data$num_n)
edges_target    <- mean(c(inedges_target, outedges_target))
cat("edges_target:", round(edges_target), "\n")

# Sex mixing targets (from meta-analysis — proportions fixed)
tgt.male.pctmale     <- edges_target * 0.60 * 0.55
tgt.male.pctfemale   <- edges_target * 0.60 * 0.44
tgt.female.pctmale   <- edges_target * 0.38 * 0.72
tgt.female.pctfemale <- edges_target * 0.38 * 0.28
sex_mixing_align_order <- c(tgt.male.pctfemale, tgt.female.pctmale, tgt.male.pctmale)

# Age mixing targets
tgt.young.pctold   <- edges_target * 0.16 * 0.52
tgt.old.pctyoung   <- edges_target * 0.84 * 0.10
tgt.young.pctyoung <- edges_target * 0.16 * 0.48
age_mixing_align_order <- c(tgt.young.pctold, tgt.old.pctyoung, tgt.young.pctyoung)

# Race mixing targets (4x4 matrix from meta-analysis; ordering matches nodemix levels2=-1)
pct_to <- c(white = 0.59, black = 0.18, hispanic = 0.17, other = 0.03)
race_mix <- matrix(c(
  0.758, 0.091, 0.111, 0.040,
  0.333, 0.495, 0.161, 0.011,
  0.345, 0.011, 0.632, 0.011,
  0.638, 0.106, 0.202, 0.053
), nrow = 4, byrow = TRUE,
dimnames = list(c("Wh","Bl","Hi","Ot"), c("Wh","Bl","Hi","Ot")))

target_race_num <- c(
  edges_target * pct_to["black"]    * race_mix["Bl","Wh"],
  edges_target * pct_to["hispanic"] * race_mix["Hi","Wh"],
  edges_target * pct_to["other"]    * race_mix["Ot","Wh"],
  edges_target * pct_to["white"]    * race_mix["Wh","Bl"],
  edges_target * pct_to["black"]    * race_mix["Bl","Bl"],
  edges_target * pct_to["hispanic"] * race_mix["Hi","Bl"],
  edges_target * pct_to["other"]    * race_mix["Ot","Bl"],
  edges_target * pct_to["white"]    * race_mix["Wh","Hi"],
  edges_target * pct_to["black"]    * race_mix["Bl","Hi"],
  edges_target * pct_to["hispanic"] * race_mix["Hi","Hi"],
  edges_target * pct_to["other"]    * race_mix["Ot","Hi"],
  edges_target * pct_to["white"]    * race_mix["Wh","Ot"],
  edges_target * pct_to["black"]    * race_mix["Bl","Ot"],
  edges_target * pct_to["hispanic"] * race_mix["Hi","Ot"],
  edges_target * pct_to["other"]    * race_mix["Ot","Ot"]
)

# --- Save outputs ---

write_csv(nodes, here("data", "synthetic", "nodes.csv"))
cat("Saved data/synthetic/nodes.csv\n")

# Bundle all targets into one object so they can be inspected together
# (e.g. `targets`, `str(targets)`, `targets$edges_target`).
targets <- list(
  edges_target           = edges_target,
  indegree_data          = indegree_data,
  outdegree_data         = outdegree_data,
  sex_mixing_align_order = sex_mixing_align_order,
  age_mixing_align_order = age_mixing_align_order,
  target_race_num        = target_race_num
)

saveRDS(targets, here("data", "synthetic", "targets.rds"))
cat("Saved data/synthetic/targets.rds\n")

# Quick overview in the console
str(targets)
targets
