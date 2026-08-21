# =============================================================================
# Module 5 (alternate): convert the exported CSV network to JSON.
#
# Why this exists:
#   05b-export-abm.R and 05c-export-json.R each call simulate(fit_final, nsim = 1)
#   independently, so they exported DIFFERENT networks (e.g. 586 vs 685 edges).
#   Instead, treat the CSV that 05b already wrote as the ONE final simulated
#   network, and re-serialize it to JSON. No new simulation -> the JSON and CSV
#   describe the identical network by construction.
#
#   Run R/05b-export-abm.R first to produce the CSVs.
# =============================================================================

suppressPackageStartupMessages({ library(here); library(readr); library(jsonlite) })

out_dir    <- here("out")
attrs_path <- file.path(out_dir, "vertex_attributes.csv")
el_path    <- file.path(out_dir, "edgelist.csv")
if (!file.exists(attrs_path) || !file.exists(el_path)) {
  stop("Run R/05b-export-abm.R first to create vertex_attributes.csv and edgelist.csv.")
}

attrs <- read_csv(attrs_path, show_col_types = FALSE)   # id, sex, young, race.num, ...
el    <- read_csv(el_path,    show_col_types = FALSE)   # from, to

# networkx node-link format (loads into networkx / Repast4Py):
#   import json, networkx as nx
#   G = nx.node_link_graph(json.load(open("net_sim.json")),
#                          directed=True, edges="links")   # edges= for nx >= 3.x
graph <- list(
  directed   = TRUE,
  multigraph = FALSE,
  graph      = structure(list(), names = character()),      # serializes as {}
  nodes      = attrs,                                        # array of node records
  links      = data.frame(source = el$from, target = el$to)
)
write_json(graph, file.path(out_dir, "net_sim.json"),
           auto_unbox = TRUE, dataframe = "rows", pretty = TRUE)

cat(sprintf("\nConverted %d agents and %d edges (from CSV) to net_sim.json.\n",
            nrow(attrs), nrow(el)))
