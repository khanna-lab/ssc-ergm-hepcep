# =============================================================================
# Module 5 (alternate): export the saved simulated network to JSON.
#
# 05b-export-abm.R simulates ONE network, writes the CSVs from it, and saves the
# object as out/net_sim.rds. This reads that SAME object and serializes it to
# JSON, so the CSV and JSON describe the identical network -- no second
# simulate(), and no lossy CSV round-trip (types come straight off the object).
#
# Run R/05b-export-abm.R first to create out/net_sim.rds.
# =============================================================================

suppressPackageStartupMessages({ library(here); library(network); library(jsonlite) })

net_path <- here("out", "net_sim.rds")
if (!file.exists(net_path)) {
  stop("Run R/05b-export-abm.R first to create out/net_sim.rds.")
}
net_sim <- readRDS(net_path)

# Node table (agents). as.integer() keeps categoricals as integers in JSON (3,
# not 3.0); race_num is a Python-valid name.
attrs <- data.frame(
  id       = as.integer(network.vertex.names(net_sim)),
  sex      = net_sim %v% "sex",
  young    = as.integer(net_sim %v% "young"),
  race_num = as.integer(net_sim %v% "race.num"),
  chicago  = as.integer(net_sim %v% "chicago"),
  lat      = net_sim %v% "lat",
  lon      = net_sim %v% "lon"
)

# Edges. as.edgelist() gives 1-based (tail, head) indices; map through id so we
# never assume index == vertex name.
el    <- as.edgelist(net_sim)
edges <- data.frame(source = attrs$id[el[, 1]], target = attrs$id[el[, 2]])

# networkx node-link format:
#   G = nx.node_link_graph(json.load(open("net_sim.json")),
#                          directed=True, edges="edges")   # edges= for nx >= 3.x
write_json(
  list(directed = is.directed(net_sim), multigraph = FALSE, nodes = attrs, edges = edges),
  here("out", "net_sim.json"),
  auto_unbox = TRUE,   # scalars as 3, not [3]
  digits     = NA)     # full lat/lon precision

cat(sprintf("\nExported %d agents and %d edges to out/net_sim.json (directed=%s).\n",
            nrow(attrs), nrow(edges), is.directed(net_sim)))
