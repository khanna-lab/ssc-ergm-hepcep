# Jonathan's Review Notes — Modules 1–3

Consolidated from the `JO-01-notes`, `JO-02-notes`, `JO-03-notes` branches
(Jonathan Ozik, 08/10–08/11/2026). Each branch is a single commit against `init`
touching one module. Below: his inline `JO:` comments as an actionable checklist,
plus the small text fixes he made directly.

**Legend:** `[ ]` open · `[~]` partly solved (see note) · `[x]` done
**Workflow:** merge each `JO-0X` branch to capture his fixes, then work these items and
delete each `JO:` comment from the slide as it's resolved.

---

## Module 1 — `modules/01-ergm-intro.qmd`

Direct fixes he made: none (all comments).

- [x] **Micro→macro framing** — tie "micro-level processes → macro-level structure" to
  **ABMs**, which the audience already knows.
- [x] **"targets" wording** — on "Where we're going" #2, consider "these network summary
  statistics become our **calibration targets**."
- [x] **"null vs. assortative mixing" is opaque** — say *why* assortative here.
- [x] **Simulate step (#4)** — add "…reproduce the empirical structures **in the form of our
  network summary statistics?**"
- [x] **Speaker notes on the ERGM-equation slide** — "do these notes go with the slide? not
  immediately clear." Check alignment.
- [x] **Define `plogis`** on the edges/intercept slide.
- [x] **Log-odds** — if used throughout this and later modules, introduce it explicitly here.
- [x] **Assortative-fit note** — big point; add intuition about finding configurations in
  network space, and how dyad-independent → dyad-dependent complicates things.
- [x] **Log-likelihood** is first used on the `nodematch` slide without context — add a brief line.
- [x] **Converged ≠ well-aligned** — add intuition for *why* this can happen.
- [x] **Triangles → degeneracy** — "this needs more explanation."

## Module 2 — `modules/02-network-targets.qmd`

Direct fixes he made: `freindships`→`friendships`, `availble`→`available`.

- [ ] **"ERGM-compatible network parameters"** → just call them **targets**.
- [ ] **"correctly-ordered vector"** — reads jargony; simplify.
- [ ] **"friend" is wrong for a syringe-sharing network** — use "connection" or something
  specific like "needle-sharing." Recurs; worth a consistent pass.
- [ ] **Degree→edge-count derivation** — "why are in/out-degrees multiplied by `mean_n` and
  not the number of people at that degree in the code snippet?" Clarify the math vs. the code.
- [ ] **"load-bearing"** — Jonathan flags it as an "AI tell." Reword; scrub for similar voice.
- [ ] **Sex-mixing slide** — define "**sent**" clearly; "within-group" isn't clear from the code.
- [ ] **`summary()` decimals** — explain why the results contain decimals (non-integer targets).
- [ ] **`levels2 = -1`** — explain the "2" (second term); note it's a choice / give a rule of thumb.
- [ ] **`age_target` / `race_target`** — not yet defined at that point (they're in the exercise);
  say so explicitly.

## Module 3 — `modules/03-sequential-ergm.qmd`

Direct fixes he made: "the default criterion **is** Hummel"; "**which** conducts a T² test";
"Hummel handles **steps** 5–6"; "simulating, **comparing** to target, and **nudging**";
"an empty or random **network**"; "Stochastic Approximation **(SA)**".

- [ ] **List the 7 steps up front** — "mention at the outset there will be 7 steps? maybe show
  them once as a table with the first two columns, then go into the per-step detail."
- [ ] **"direct MLE estimation" is redundant** — use "MLE" or "maximum likelihood estimation (MLE)."
- [~] **Why is Hummel hard at full scale?** — *we can answer this now.* Under SA there's still a
  final MCMLE/Newton-Raphson polish step; at n≈32k with `MCMC.interval = 1e6`, Hummel's adaptive
  stepping is expensive enough to exhaust walltime while Hotelling's simpler T² stops sooner.
  Matched-pair evidence in `net-ergm-v4plus/slurm_output/*int1e6-sampsize1e6-{hummel,hotelling}`.
  → write a one-line intuition into the slide.
- [ ] **Footnotes for references** — Jonathan asks whether to footnote in-slide citations
  (Robbins–Monro, etc.). Decide on a convention.
- [ ] **"Here we carry the network forward"** — ambiguous "here"; clarify it refers to the
  network-carrying option, not the coefficient-init option above it.
- [~] **"where is `net_warm` defined?"** — Jonathan independently caught the `net_mix` vs
  `net_warm` naming inconsistency (fit5 uses `net_mix`, fit6 uses `net_warm`). Make the
  carried-network naming consistent across the warm-start blocks.

---

## Cross-cutting / recurring

- **Add intuition, not just mechanics** — the single most common request across all three
  modules (why assortative, why degeneracy, why converged≠aligned, why Hummel struggles).
- **Terminology for the domain** — "friend" → needle-sharing/connection; "targets" over
  "network parameters"; watch jargon ("correctly-ordered vector").
- **Voice scrub** — "load-bearing" flagged as an AI tell; do a light pass for similar phrasing.
- **Citations convention** — decide footnotes vs inline (Module 3 prompt, applies throughout).
