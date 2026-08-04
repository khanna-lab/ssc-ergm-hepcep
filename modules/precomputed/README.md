# Precomputed outputs

Everything Module 1's slides display, generated ahead of time so the deck renders
with **zero R execution** — it only reads these files (text includes + images).
`statnet` never loads at render.

## Two-step build (fitting separated from output)

```bash
Rscript R/precompute-intro-fit.R    # 1. fit the 3 models  -> out/intro-fits.rds (gitignored)
Rscript R/precompute-intro-gof.R    # 2. write all outputs  -> the files below
```

Re-run step 2 whenever you tweak GOF seeds or figures; re-run step 1 only when a
model spec changes.

| File(s) | What | Read by (in `01-ergm-intro.qmd`) |
|---------|------|----------------------------------|
| `out-size/grade/sex/mixing/degree/targets/null/assort/gwesp.md` | numeric summaries as fenced text (searchable) | `{{< include … >}}` |
| `gof-null/assort/gwesp.png` | degree goodness-of-fit plots | `![](…)` |
| `netplot.png` | friendship network, colored by grade | `![](…)` |
| `obs-vs-sim.png` | observed vs. simulated (assortative) | `![](…)` |

All committed, so the slides render on any machine (and Posit Cloud) with no R.
