# Full HepCEP Synthetic Population

This directory holds the full HepCEP synthetic population of people who inject
drugs (PWID):

- `synthpop-2023-10-12 12_01_32.csv` (~32k nodes)

It is a *synthetic* population (simulated node attributes, not real individuals),
sourced from the public HepCEP repo: https://github.com/hepcep/net-ergm-v4plus
(`data/`). The dated filename is kept for provenance.

## How it is used

`R/generate-synthetic-data.R` samples n=1000 nodes from this file and computes the
target statistics, writing the workshop dataset to `data/synthetic/`
(`nodes.csv`, `targets.rds`). The modules use that n=1000 subset, which is small
enough for live ERGM convergence during the workshop.

## Contacts

- Aditya Khanna (aditya_khanna@brown.edu)
- Jonathan Ozik (jozik@anl.gov)
