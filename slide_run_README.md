# Rendering and publishing the slides

Written using **R 4.6** and **Quarto**.

## Render

```bash
git clone git@github.com:khanna-lab/ssc-ergm-hepcep.git
cd ssc-ergm-hepcep
Rscript -e 'renv::restore()'              # install the pinned packages
quarto render                             # all six modules
quarto render modules/01-ergm-intro.qmd   # or just one
```

Output is generated in `_output/modules/`. Each deck is self-contained
(`embed-resources: true` in `_quarto.yml`), so a single `.html` file carries its own
images, CSS and JS — there are no sidecar asset folders to copy alongside it.

## Publish

The live site is served by GitHub Pages from `docs/` on the `init` branch:

<https://khanna-lab.github.io/ssc-ergm-hepcep/>

`_output/` is gitignored, so publishing is a deliberate copy rather than a side effect
of rendering:

```bash
quarto render
cp _output/modules/*.html docs/
git add docs && git commit -m "Update rendered decks" && git push
```

Pages redeploys on push; allow a minute or two.

Notes on `docs/`:

- `index.html` is the hand-written landing page. Quarto does not generate it, so a
  re-render will never overwrite it — edit it directly when module titles change.
- `.nojekyll` (empty file) tells Pages to serve the folder as-is instead of running it
  through Jekyll.
- `00-preamble.html` has no `.qmd` source in this repo, so `quarto render` does not
  regenerate it. Leave it in place.

## Notes

- R 4.6 is pinned in `renv.lock`. R 4.5.x renders fine, but `renv::restore()` will try
  to build `nlme` from source (4.5 ships an older version than the lockfile records),
  which needs a Fortran compiler. R 4.6 ships the pinned version, so nothing compiles.
  [rig](https://github.com/r-lib/rig) is a convenient way to keep several R versions
  side by side: `rig add 4.6.1` then `rig default 4.6`.
- Nothing executes at render time (`eval: false` in `_quarto.yml`) — the code in the
  modules is there to be read. Only `knitr`/`rmarkdown` are strictly needed to build
  the decks; the full `renv::restore()` is what you want in order to *run* the
  workshop code.
- Current idea is that the code embedded in the modules is for illustrative purposes.
- I am thinking I will generate student-facing r code files for actually running the analyses.
- May change later, but that's the current idea.
