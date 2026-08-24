# From Aggregate Network Summaries to Synthetic Networked Populations

**SSC 2026 Workshop**
Aditya Khanna (Brown University School of Public Health) & Jonathan Ozik (Argonne National Laboratory / University of Chicago)

## Overview

This workshop focuses on workflow design, diagnostics, and judgment in generating networked populations using exponential random graph models (ERGMs) for social simulation. The running example is syringe-sharing networks among people who inject drugs (PWID), used to simulate vaccine interventions in an agent-based modeling framework.

**Duration:** 3 hours (6 modules × ~30 min)
**Format:** Hands-on; participants run code in each module

## Prerequisites

- Familiarity with logistic regression
- R experience preferred (RStudio recommended)
- No prior ERGM experience required — a brief introduction is provided

## Setup

### Posit Cloud (recommended for workshop)
**Join link:** shared at the start of the workshop (no local installation required)


## Modules

Each module pairs a slide deck (`modules/`) with a hands-on exercise (`exercises/`).

| Module | Deck | Exercise | Focus |
|--------|------|----------|-------|
| 1 | `01-ergm-intro.qmd` | `01-intro.qmd` (take-home) | Brief ERGM intro (Add Health friendships example) |
| 2 | `02-network-targets.qmd` | `02-targets.qmd` | Aggregate summaries → network targets |
| 3 | `03-sequential-ergm.qmd` | `03-sequential.qmd` | Sequential ERGM specification |
| 4 | `04-failure-modes-and-diagnostics.qmd` | `04-failure-modes.qmd` | Assessing failure modes via diagnostics |
| 5 | `05-simulation-diagnostic.qmd` | `05-simulation.qmd` | Simulation as diagnostic + ABM export |
| 6 | `06-geographic-extensions.qmd` | `06-geographic.qmd` | Geographic extensions (custom `dnf` term) |

## Data

The workshop uses a synthetic dataset (`data/synthetic/`) designed to mirror the structural properties of real PWID syringe-sharing networks from the Chicago area, with n=1000 nodes. See `data/full/README.md` for information on accessing the full HepCEP dataset.

## Reference

A preliminary version of this workflow is published in:
- Boodram et al. (2022). *PLOS ONE*. [DOI: 10.1371/journal.pone.0248850]
- Workshop content is being written up as a new manuscript.


