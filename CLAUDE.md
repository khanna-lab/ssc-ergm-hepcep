# SSC 2026 ERGM Workshop — Project Context

## Workshop Overview
**Title:** From Aggregate Network Summaries to Synthetic Networked Populations: Reproducible Workflows for Social Simulation Leveraging ERGMs for ABMs

**Co-organizers:** Aditya Khanna (Brown SPH) & Jonathan Ozik (Argonne/UChicago)
**Conference:** SSC 2026
**Format:** 6 modules × ~30 min = 3 hours, hands-on

## Delivery Stack
- **Quarto revealjs** — one .qmd per module; code + slides in one file
- **Posit Cloud** — pre-loaded workspace for participants without local R setup
- Participants run code themselves during each module

## Audience
Familiarity with logistic regression assumed; R experience preferred. Brief ERGM intro provided at the start.

## Module Structure
| # | Focus | Key Activity |
|---|-------|-------------|
| 1 | A brief introduction to ERGMs | Fit and simulate on an observed network (`faux.magnolia.high`), building to the targets idea |
| 2 | Aggregate summaries → network targets | Convert empirical summaries (mixing, degree distributions) into an ordered ERGM target vector |
| 3 | Sequential ERGM specification | Staged ERGM fitting walkthrough toward convergent model |
| 4 | Assessing failure modes | Compare non-converged/poorly aligned models |
| 5 | Simulation as diagnostic | Generate simulated networks, assess vs. targets, crosswalk to ABM inputs |
| 6 | Geographic extensions | Custom ERGM terms for geocoded data, via the `dnf` distance term |

## Dataset
- **Synthetic dataset** (`data/synthetic/`): n=1000 nodes, mirroring HepCEP PWID syringe-sharing network structure
- Attributes: age, race/ethnicity, sex, geocoded location (simulated Chicago-area coordinates)
- Small enough for live ERGM convergence during the workshop
- **Full data placeholder** (`data/full/`): instructions for accessing the full HepCEP dataset post-workshop

## Reference Repositories
- `hepcep/net-ergm-v4plus` — source of the full HepCEP ERGM pipeline (main + dnf branches)
- The workshop pipeline is a pedagogically simplified version of that pipeline
- `hepcep/ergm.userterms.hepcep` — the custom `dnf`/`dist` geographic terms used in
  Module 6 (https://github.com/hepcep/ergm.userterms.hepcep). Not on CRAN; installs
  from GitHub and compiles against `ergm` (>= 4.8.0)

## Key R Packages
- `ergm`, `network`, `statnet.common`, `ergm.userterms.hepcep` (custom terms for geocoded mixing)
- `sna`, `ggplot2`, `dplyr`, `readr`
