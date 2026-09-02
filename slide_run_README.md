# Rendering and publishing the slides

Written using **R 4.6** and **Quarto**.

## Render

```bash
git clone git@github.com:khanna-lab/ssc-ergm-hepcep.git
cd ssc-ergm-hepcep
Rscript -e 'renv::restore()'              # install the pinned packages
quarto render                             # all seven decks
quarto render modules/01-ergm-intro.qmd   # or just one
```

Output is generated in `_output/modules/`. Each deck is self-contained
(`embed-resources: true` in `_quarto.yml`), so a single `.html` file carries its own
images, CSS and JS. There are no sidecar asset folders to copy alongside it.

## Publish

The live site is served by GitHub Pages from `docs/` on the `init` branch:

<https://khanna-lab.github.io/ssc-ergm-hepcep/>

`_output/` is gitignored, so publishing is a deliberate copy rather than a side effect
of rendering. There is no CI: if you skip the copy, the site keeps serving the previous
decks and nothing warns you. Run the whole block:

```bash
quarto render                    # 1. build into _output/modules/
cp _output/modules/*.html docs/  # 2. THIS IS THE STEP THAT IS EASY TO FORGET
git status                       # 3. expect 7 modified .html files under docs/
git add -A && git commit -m "Update rendered decks" && git push
```

Then confirm it actually deployed, which is a separate step from the push and takes a
minute or two:

```bash
# should print the commit you just pushed
git log --oneline -1

# should differ from the old build; hard-refresh in the browser to be sure
curl -s https://khanna-lab.github.io/ssc-ergm-hepcep/02-network-targets.html | wc -c
```

If the site looks stale, check the `pages build and deployment` run in the Actions tab
before assuming something is broken locally. Pages serves from its own copy, so a
successful push is not the same as a successful deploy.

Notes on `docs/`:

- `index.html` is the hand-written landing page. Quarto does not generate it, so a
  re-render will never overwrite it. Edit it directly when module titles change, or
  when adding a module to the list.
- `.nojekyll` (empty file) tells Pages to serve the folder as-is instead of running it
  through Jekyll.
- Every deck in `docs/`, including `00-preamble.html`, is generated from a `.qmd` in
  `modules/`. Never hand-edit the deck HTML; the next render will overwrite it.
- Rendered decks are committed to the repo, so each render adds a few MB to history.
  Tolerable at this size. If it becomes a problem, the fix is a GitHub Action that
  builds and deploys the site, letting `docs/` drop out of version control.

## Notes

- R 4.6 is pinned in `renv.lock`. R 4.5.x renders fine, but `renv::restore()` will try
  to build `nlme` from source (4.5 ships an older version than the lockfile records),
  which needs a Fortran compiler. R 4.6 ships the pinned version, so nothing compiles.
  [rig](https://github.com/r-lib/rig) is a convenient way to keep several R versions
  side by side: `rig add 4.6.1` then `rig default 4.6`.
- Nothing executes at render time (`eval: false` in `_quarto.yml`). The code in the
  modules is there to be read. Only `knitr`/`rmarkdown` are strictly needed to build
  the decks; the full `renv::restore()` is what you want in order to *run* the
  workshop code.
- Two `include-after-body` files in `_quarto.yml` apply to every deck:
  `reveal-keyboard.html` stops reveal.js from swallowing Cmd/Ctrl chords, and
  `reveal-backlink.html` adds the "All slides" link back to `index.html`. That link
  only appears where a sibling `index.html` exists, so it shows on the published site
  and hides itself in a local `_output/` preview. That is deliberate, not a bug.
- `history: false` in `_quarto.yml` keeps slide changes out of the browser history, so
  Back leaves the deck and returns to the landing page instead of stepping backwards
  through slides. Quarto defaults this to `true`.
- Current idea is that the code embedded in the modules is for illustrative purposes.
- I am thinking I will generate student-facing r code files for actually running the analyses.
- May change later, but that's the current idea.
