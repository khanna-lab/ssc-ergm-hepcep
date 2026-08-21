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
| `04-failure-modes.R` | 4 | Demonstrate degeneracy (`odegree(0:3)` at n=1000), MCMC diagnostics, GOF |
| `05a-simulation.R` | 5 | Simulate networks, compare summaries to targets (violin plots) |
| `05b-export-abm.R` | 5 | Export edgelist + node-attribute table for the ABM |
| `05c-export-json.R` | 5 | Same export as node-link JSON (one file, read by `networkx.node_link_graph()`); needs `jsonlite` |

(No `03-`, because Module 3 is folded into `02-sequential.R`. Module 6 covers the
geographic `dnf` term and has no script of its own; its examples are self-contained
in `modules/06-geographic-extensions.qmd`.)

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
- **Light MCMC controls** (defaults; only the final in+out-degree step needs
  Stochastic-Approximation) instead of SA everywhere with `MCMC.* = 1e6`. Note the
  dyad-independent mixing block still fits by MCMC, not closed-form MLE, because the
  targets are non-integer expected counts.
- **Geography:** `nodematch("chicago")` stand-in instead of the custom `dnf`
  distance term from [`hepcep/ergm.userterms.hepcep`](https://github.com/hepcep/ergm.userterms.hepcep),
  which installs from GitHub and compiles against `ergm`. The swap-in point and the
  real targets are noted in `02-sequential.R`, and Module 6 walks through the term.
- The geographic target is derived from an assumed within-area mixing fraction
  (`p_within_chicago` in `00-setup.R`); the real pipeline uses empirical
  distance proportions.

## To verify when you first run it

- Target-vector ordering for `nodemix(..., levels2 = -1)` matches the term
  order (the alignment vectors come from the full pipeline; confirm against
  `summary(net ~ nodemix("sex", levels2 = -1))`).
- Degree-term targets line up with `outdegree_data` / `indegree_data` rows.
