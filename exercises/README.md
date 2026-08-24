# Workshop Exercises

Hands-on companions to the six module decks. Each exercise is a **scaffolded Quarto
notebook** (`.qmd`) we complete during (or after) the corresponding module. Fill in
each `# TODO`, run the chunk, and check the result against the slides.


## Environment

Everything runs in the shared **Posit Cloud** project (a copy of this repo with
`renv` restored and the synthetic data in place). No local install needed.

👉 **Join link:** <https://posit.cloud/spaces/807716/join?access_code=AaeD4Bo2EEcgQL6-oA2QDCdZFqeHabvuucl8oTu1>


## Loading and Set-Up

1. Open the **[join link](https://posit.cloud/spaces/807716/join?access_code=AaeD4Bo2EEcgQL6-oA2QDCdZFqeHabvuucl8oTu1)**.
2. **Sign in** to Posit Cloud (or **sign up** if it's your first time).
3. The space opens. Click the project to launch it; RStudio loads (first launch takes a moment).
4. Arrange the panes however you like — we mainly need the **Source qmd file**, **Console** and **Files**.
5. In the Console, run `renv::restore()` to sync the library. It should report
   *"already synchronized with the lockfile."* (If prompted about `pandoc`, answer **Y** — harmless.)



## How to use

- Open the exercise for the current module (e.g. `exercises/01-intro.qmd`) in
  RStudio / Posit Cloud.
- Work top to bottom. Run each code chunk with the green ▶ ("Run current chunk")
  button before moving on — no rendering needed.
- `# TODO:` marks a line to be completed. A hint follows in the comment.
- Each notebook ends with a collapsible **Solution** callout; the full, working
  version is the matching script in `R/` (noted at the top of each exercise).
