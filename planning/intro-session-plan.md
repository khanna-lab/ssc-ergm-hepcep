# Intro Session Plan — Module 0 (Brief Introduction to ERGMs)

**SSC 2026 ERGM Workshop** · Khanna & Ozik · **30 min, standalone**

The opening block is now a full 30-min gentle on-ramp: `modules/00-ergm-intro.qmd`,
a condensed version of Aditya's "Modeling Social Relations using ERGMs" talk. It uses the
Add Health friendship example (`faux.magnolia.high`, built into `statnet`) and builds to
the concept of **network targets** — the idea that drives the rest of the day. Module 1
(PWID hands-on) follows in the next slot.

**Robustness:** Module 0 has **no workshop-data dependency** — it runs on built-in data, so
it works even if the Posit Cloud data load (B1, below) isn't ready. The data/naming
blockers now affect Module 1, not the intro.

## Goal
Participants leave able to: explain an ERGM as "logistic regression for ties"; read a
mixing matrix and degree distribution; **define a network target** and say why we fit to
targets (`target.stats`) rather than always needing a full observed network; and describe
why simulation is the real test of fit.

## 30-min run sheet
| Time | Beat | Slides |
|------|------|--------|
| 0–3 | Welcome + framing: micro processes → macro structure | Why this intro; The question |
| 3–5 | Roadmap: describe → summarize → model → simulate | Where we're going |
| 5–13 | **Explore the structure** (live or baked): size/ties, attributes, mixing matrix, degree distribution | The data; Who's in the network; Structure ×2 |
| 13–18 | **Network targets** — summaries *are* statistics; `target.stats`; why this matters when you only have aggregate data | These summaries are statistics; What is a target? |
| 18–24 | Models: null (edges) → assortative (`nodematch`) → interpret (~22×) | Null; Assortative; Interpretation |
| 24–28 | Simulation as the real test of fit (GOF on degree); what's still missing (triadic closure) | Is it good enough?; What's missing? |
| 28–30 | Takeaway + handoff to Module 1 (targets from empirical summaries, PWID) | Takeaway |

**Pacing:** the **targets** section (13–18) is the conceptual payload — protect it. The
descriptives before it exist to make "target" concrete, not to linger on.

## Code mode
Module 0 chunks are executable (`eval: true`) so outputs and the GOF plot bake into the
rendered deck — the target counts are *visible*, which is the point. Requires R + `statnet`
at render time. Flip to `eval: false` if you'd rather run live / avoid the dependency.

## Common stumbles
"Where do `target.stats` come from?" — here, the observed counts; in Module 1, meta-analysis
summaries. · Reading a mixing matrix (diagonal = within-group). · Non-convergence on simple
fits is fine → that's Module 4. · `nodematch` (same-attribute ties) vs `nodemix`
(every attribute combination) — Module 1 uses `nodemix`.

## Downstream (not this block, but don't forget)
Module 1 still needs: **B1** committed `data/synthetic/nodes.csv` + `targets.rds` in the
Posit Cloud image; **B2** `race.num`/`race_num` reconciled; **B3** packages present;
**B4** separate `eval: true` instructor key.

## Open decisions
1. **Descriptives depth** — keep all four summaries (overview, attributes, mixing, degree),
   or drop attributes/overview to give the targets section more air?
2. **Triadic-closure teaser** — keep it (previews Module 4 degeneracy) or cut for time?
3. **Instructor key** — want me to build the `eval: true` Module 1 version too?
