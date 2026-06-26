# Workshop ERGM pipeline

A simplified, runnable version of the HepCEP ERGM pipeline
(`hepcep/net-ergm-v4plus`), on the n=1000 synthetic dataset. The scripts are
modular and mirror the presentation modules (the geographic term is folded into
the sequential fit, where it lives in the real pipeline).

| Script | Module | Does |
|--------|--------|------|
| `00-setup.R` | shared | Load nodes + targets, build the directed network, light controls, helpers |
| `01-targets.R` | 1 | Re-derive each target statistic from the empirical summaries; confirm vs `targets.rds` (no fitting) |
| `02-sequential.R` | 2-3 | Staged, warm-started fit to the final model; geographic mixing folded in as the `nodematch("chicago")` stage (stand-in for the custom `dnf` term) |
| `03-failure-modes.R` | 4 | Demonstrate degeneracy (`odegree(0:2)`), MCMC diagnostics, GOF |
| `04-simulation.R` | 5 | Simulate networks, compare summaries to targets (violin plots) |
| `05-export-abm.R` | 6 | Export edgelist + node-attribute table for the ABM |

## Run it

```r
# from the project root, in R (renv-activated)
source("R/run-all.R")          # full pipeline end-to-end
# or run one module (each sources 00-setup.R if needed):
source("R/02-sequential.R")
```

Prerequisite: `R/generate-synthetic-data.R` has been run, producing
`data/synthetic/nodes.csv` and `targets.rds`. Outputs land in `out/`
(gitignored).

## Simplifications vs. the full pipeline

- **n = 1000** instead of 32k, so models converge live.
- **Light MCMC controls** (`MCMC.* = 1024`, MLE for dyad-independent terms)
  instead of Stochastic-Approximation with `MCMC.* = 1e6`.
- **Geography:** `nodematch("chicago")` stand-in instead of the custom `dnf`
  distance term from `ergm.userterms.hepcep` (which needs compiling). The
  swap-in point and the real targets are noted in `02-sequential.R`.
- The geographic target is derived from an assumed within-area mixing fraction
  (`p_within_chicago` in `00-setup.R`); the real pipeline uses empirical
  distance proportions.

## To verify when you first run it

- Target-vector ordering for `nodemix(..., levels2 = -1)` matches the term
  order (the alignment vectors come from the full pipeline; confirm against
  `summary(net ~ nodemix("sex", levels2 = -1))`).
- Degree-term targets line up with `outdegree_data` / `indegree_data` rows.
