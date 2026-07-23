# Module 3 Outline — Sequential ERGM Specification

**SSC 2026** · Khanna & Ozik · ~30 min, hands-on. Sources: `R/02-sequential.R`,
`R/control-settings.md`, `fit-stepwise-ergms.R` (real pipeline).

Picks up from Module 2's `target_vec`; builds a **convergent** ERGM by adding
terms in stages, warm-starting each from the prior simulation.

**Goal:** why stage instead of fit-all-at-once; use `simulate()` to warm-start;
tell "runs" from "converges"; know when to override `ergm` defaults.

## Fitting sequence (n=1000)
| Step | Terms | Fit |
|---|---|---|
| 1–4 | `edges + nodemix(sex/young/race.num) + nodematch("chicago")` | Exact MLE |
| 5–6 | `+ odegree(0)`, then `+ odegree(0:1)` | MCMLE/SA |
| 7 | `+ idegree(0:1) + odegree(0:1)` | SA — hard step |

Geography already in Module 2, not a new stage. Real pipeline (instructor-only
background) also tries `odegree(0:2)` — degenerate, teaser for Module 4.

## Warm-starting
`net_warm <- simulate(fit_k, nsim = 1)` → LHS for step k+1. Right low-order
structure already present converges faster than empty/random start.

## Default vs. override
Two knobs: **algorithm** (MCMLE → Stochastic-Approximation) and **convergence
rule** (Hummel step-length → Hotelling T², + fixed MCMC thinning). Defaults hold
through mixing + one degree direction; combined in/out-degree needs the
override. Override smallest thing first; diagnose via a second simulation, not
fit-object diagnostics. ⚠️ **Currently just an empirically-derived recipe —
before the workshop, understand *why* SA+Hotelling succeeds where MCMLE+Hummel
stalls, not just *that* it does** (see "Before workshop" below).

## Run sheet (30 min)
0–8 recap + sequence/mixing · 8–13 warm-starting · 13–15 degree steps 5–6 ·
15–24 hard step, pre-baked default-vs-override, live optional · 24–28 recap ·
28–30 Module 4 teaser.

## Resolved
Hard step: pre-baked primary, live optional. No n=32k anywhere. Geography
confirmed in Module 2.

## Open
Instructor key (live vs. baked) — decide per-module once 4–6 outlined.

## Before workshop
Get a real handle on Hummel/Hotelling + MCMLE/SA (statnet-help thread, Hummel
2012 paper) — not urgent, flagged.
