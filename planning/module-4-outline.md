# Module 4 Outline — Assessing Failure Modes

**SSC 2026** · Khanna & Ozik · ~30 min, hands-on. Sources: `R/04-failure-modes.R`,
`net-ergm-v4plus/fit-ergms/diagnose-rix-race-degen.R` and
`investigate-mcmc-diagnostics.R` (real pipeline).

Opens with Module 3's teaser resolved: `+ odegree(0:2)` on the converged
mixing block is **degenerate**. Module 4 gives participants the vocabulary and
tools to recognize *why* a fit failed, not just *that* it did.

**Goal:** distinguish technical non-convergence, degeneracy, and poor
alignment — three different failures with three different fixes. Read
`mcmc.diagnostics()` output. Use `gof()` and a second simulation to check a
*converged* model actually matches targets.

## Three kinds of failure
| Type | Symptom | Fix |
|---|---|---|
| Technical non-convergence | Chains don't mix; step lengths collapse | More iterations, switch algorithm (Module 3's SA/Hotelling) |
| Degeneracy | Simulated networks near-empty or near-complete; `ergm` may error outright | Remove/reparameterize the term — not a tuning problem |
| Poor alignment | Converges fine, but simulated stats ≠ targets | Revisit model spec or targets, not the fitting controls |

## Worked degeneracy example
`+ odegree(0:2)` on top of the converged mixing block (`R/04-failure-modes.R`,
`fit_to_targets()` + `tryCatch`). An `ergm()` error here is itself a
degeneracy signature worth naming, not just a bug to catch. If it does return
a fit, compare simulated edge count to `edges_target` — degenerate = wildly
off (near 0 or near-complete).

## MCMC diagnostics
`mcmc.diagnostics(fit)` on the *converged* Module 3 model. What to look for:
flat/drifting traces (non-mixing), autocorrelation that doesn't decay, Geweke
statistic far from 0. Frame as: diagnostics assess the **algorithm's**
behavior, not whether the **model** is any good — that's GOF's job, next.

## GOF: is convergence enough?
`gof(fit_final, GOF = ~ idegree + odegree)` — simulate many networks from the
converged fit, compare distributions to targets. Ties back to Module 3's
"diagnose via a second simulation, not fit-object diagnostics" rule: this
*is* that second simulation.

## Run sheet (30 min)
0–5 recap Module 3 teaser, resolve it live · 5–12 degeneracy example, edge-count
sanity check · 12–18 `mcmc.diagnostics()` on converged vs. degenerate ·
18–25 `gof()` on the converged model · 25–28 three-failure-types recap ·
28–30 handoff to Module 5 (simulation as the systematic version of today's GOF
check).

## Open decisions
1. **Live vs. baked for the degenerate fit.** It may error out or hang —
   same risk class as Module 3's hard step. Leaning pre-baked console
   output/error message as primary, consistent with Module 3's resolution.
2. **How much MCMC-diagnostics theory vs. pattern-matching.** Full traceplot
   interpretation is a course in itself — suggest: show one bad and one good
   traceplot side by side, name the visual signature, skip the underlying
   Geweke-statistic math.
3. **Instructor key** — same open question as Module 3, still pending a
   whole-day pass once Modules 5–6 are outlined.
