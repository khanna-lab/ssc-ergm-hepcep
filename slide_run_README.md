# Rendering the slides

Written using **R 4.6** and **Quarto**.

```bash
git clone git@github.com:khanna-lab/ssc-ergm-hepcep.git
cd ssc-ergm-hepcep
Rscript -e 'renv::restore()'          # install the pinned packages
quarto render modules/01-ergm-intro.qmd
```

Output is generated in `_output/modules/`.

Notes:
- R 4.6 pinned in `renv.lock`. Also tested with R/4.5.1.
- Current idea is that the code embedded in the modules is for illustrative purposes.
- I am thinking I will generate student-facing r code files for actually running the analyses. 
- May change later, but that's the current idea. 

