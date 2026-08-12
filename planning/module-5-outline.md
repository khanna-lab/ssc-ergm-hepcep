# Module 5 Outline — Simulation as Diagnostic

**SSC 2026** · Khanna & Ozik · ~30 min, hands-on. Sources: `R/05a-simulation.R`
(built, working), archived `05-simulation-diagnostic.qmd` draft.

Picks up from Module 4's `gof()` call and asks: what does that actually check,
and is it the right check for a model fit to *targets*, not an observed network?

**Goal:** distinguish what `gof()` compares against (a fitted/pseudo-observed
network) from what manual simulation compares against (your empirical
targets, directly). Simulate an ensemble and read a violin-plot comparison.
Know what good vs. poor alignment looks like, and what poor alignment implies
for going back to Module 3.

## Two approaches to "goodness of fit"
| Approach | Compares simulated nets to | Fits when |
|---|---|---|
| `gof()` (Module 4) | The fitted/pseudo-observed network (SAN-reconstructed) | You fit to a real observed network |
| Manual simulation (this module) | Your empirical target vector, directly | You fit to `target.stats` — our whole workshop |

::: {.punch}
"Converged" and "matches our empirical numbers" are not the same claim.
:::

## The workflow (already built, `R/05a-simulation.R`)
```r
sims <- simulate(fit_final, nsim = 100)
sim_stats <- t(sapply(sims, function(s) summary(s ~ edges + odegree(0:1) +
                                                    idegree(0:1) + nodematch("chicago"))))
# violin per statistic, faceted, target as a red hline
```
Numeric companion: per-statistic target, simulated mean, and 95% interval —
useful when the plot alone is ambiguous.

## Reading the result
- **Good alignment:** target falls inside the bulk of the simulated
  distribution, no systematic one-sided bias, distribution isn't absurdly wide
- **Poor alignment:** target sits outside the distribution (or at an extreme
  tail) → points at *which* term is misspecified, and loops back to Module 3
  with a revised model — not a "just refit" problem

## Run sheet (30 min)
0–5 recap Module 4's `gof()`, pose today's question · 5–10 the two-approaches
distinction · 10–18 run the simulation, read the faceted violin plot ·
18–24 good vs. poor alignment, worked from the numeric table · 24–28 crosswalk
to the ABM (`R/05b-export-abm.R`: a simulated network → agents + partnerships) ·
28–30 handoff to Module 6 (**spatial modeling** — replace the `nodematch("chicago")`
stand-in with a custom distance-based term).

The ABM crosswalk (`05b`) is part of **this** module, not Module 6. Module 6 is
spatial modeling.

## Open decisions
1. ~~Degree-only or add a mixing-matrix example?~~ **Decided: degree-only** —
   matches `R/05a-simulation.R`, keeps the module tight and terse.
2. **Instructor key** — same open question carried from Modules 3–4.
