# Workshop Exercises

Hands-on companions to the six module decks. Each exercise is a **scaffolded Quarto
notebook** (`.qmd`) we complete during (or after) the corresponding module. Fill in
each `# TODO`, run the chunk, and check the result against the slides.

## How to use

- Open the exercise for the current module (e.g. `exercises/01-intro.qmd`) in
  RStudio / Posit Cloud.
- Work top to bottom. Run each code chunk with the green ▶ ("Run current chunk")
  button before moving on — no rendering needed.
- `# TODO:` marks a line to be completed. A hint follows in the comment.
- Each notebook ends with a collapsible **Solution** callout; the full, working
  version is the matching script in `R/` (noted at the top of each exercise).

## Environment

Everything runs in the shared **Posit Cloud** project (a copy of this repo with
`renv` restored and the synthetic data in place). No local install needed.

| Exercise | Module | Solution key (`R/`) |
|---|---|---|
| `01-intro.qmd` | 1 — Intro to ERGMs | `precompute-intro-fit.R` |
| `02-targets.qmd` | 2 — Aggregate summaries → targets | `01-targets.R` |
| `03-sequential.qmd` | 3 — Sequential fitting | `02-sequential.R` |
| `04-failure-modes.qmd` | 4 — Failure modes & diagnostics | `04-failure-modes.R` |
| `05-simulation.qmd` | 5 — Simulation + ABM export | `05a-simulation.R`, `05b-export-abm.R` |
| `06-geographic.qmd` | 6 — Geographic extensions | `modules/06-geographic-extensions.qmd` |

Exercises 2–5 rely on `R/00-setup.R` (loads the synthetic network, targets, and
degree-target helpers); each sources it at the top. Exercise 1 is self-contained
on `faux.magnolia.high`, which is included in the `statnet` R library. Exercise 6
is self-contained on a three-node example but needs `ergm.userterms.hepcep`, the
custom-term package (pre-installed in Posit Cloud; see Module 6 to install it
locally). Only its "Try at home" items use `R/00-setup.R`.
