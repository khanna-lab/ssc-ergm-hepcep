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

### Option A: Posit Cloud (recommended for workshop)
[Link to be provided] — no local installation required

### Option B: Local R
1. Clone this repo: `git clone https://github.com/khanna-lab/ssc-ergm-hepcep.git`
2. Open the project in RStudio
3. Restore dependencies: `renv::restore()`
4. Install Quarto: https://quarto.org/docs/get-started/

## Modules

| Module | File | Focus |
|--------|------|-------|
| 1 | `modules/01-ergm-intro.qmd` | Brief ERGM intro (Add Health friendships example) |
| 2 | `modules/01-network-targets.qmd` | Aggregate summaries → network parameters |
| 3 | `modules/03-sequential-ergm.qmd` | Sequential ERGM specification |
| 4 | `modules/04-failure-modes-and-diagnostics.qmd` | Assessing failure modes via diagnostics |
| 5 | `modules/05-simulation-and-translation-to-abms.qmd` | Simulation and translation to ABMs |
| 6 | `modules/06-geocoded-mixing.qmd` | Geocoded attributes → social mixing |

## Data

The workshop uses a synthetic dataset (`data/synthetic/`) designed to mirror the structural properties of real PWID syringe-sharing networks from the Chicago area, with n=1000 nodes. See `data/full/README.md` for information on accessing the full HepCEP dataset.

## Reference

This workshop pipeline is based on:
- Boodram et al. (2022). *PLOS ONE*. [DOI: 10.1371/journal.pone.0270052]
- The `hepcep/net-ergm-v4plus` repository

The brief ERGM introduction (Module 0) condenses a longer talk, "Modeling Social Relations using ERGMs":
- [Full slides (Google Slides)](https://docs.google.com/presentation/d/1sF-Py8mq_fNuZViK_IT7bEQB-f5hcjhid-fB4H1JiBg/edit)
