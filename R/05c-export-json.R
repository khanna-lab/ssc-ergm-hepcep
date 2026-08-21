# Module 5: networks -> ABM inputs. Export a simulated network as node-link JSON,
# a single file Python reads with one networkx.node_link_graph() call. Same content
# as 05b-export-abm.R's two CSVs, but node ids, attribute types (integer vs. double),
# and directedness all survive the round trip.
#
# Node-link format — one object with four keys:
#   directed    bool, selects Graph vs. DiGraph on the Python side
#   multigraph  bool, whether parallel edges are allowed
#   nodes       array of objects, each with an "id"; every other key becomes a
#               node attribute (so the vertex table maps to it row for row)
#   edges       array of objects, each with "source" and "target" holding node
#               *ids*; any further key becomes an edge attribute
# An optional "graph" key holds graph-level attributes; omitted here, and networkx
# defaults it to empty.
if (!exists("net") || !"package:ergm" %in% search()) source(here::here("R", "00-setup.R"))

if (!requireNamespace("jsonlite", quietly = TRUE)) {
  stop("Package 'jsonlite' is required: install.packages('jsonlite')")
}

fit_final_path <- file.path(out_dir, "fit_final.rds")
if (file.exists(fit_final_path)) {
  fit_final <- readRDS(fit_final_path)
} else {
  source(here::here("R", "02-sequential.R"))
}

# One representative simulated network
net_sim <- simulate(fit_final, nsim = 1)

# Vertex attribute table (agents). as.integer() on the categorical attributes keeps
# them integers in the JSON; R stores them as double, which would otherwise reach
# Python as 3.0 rather than 3. race_num is underscored to stay a valid Python name.
attrs <- data.frame(
  id       = as.integer(network.vertex.names(net_sim)),
  sex      = net_sim %v% "sex",
  young    = as.integer(net_sim %v% "young"),
  race_num = as.integer(net_sim %v% "race.num"),
  chicago  = as.integer(net_sim %v% "chicago"),
  lat      = net_sim %v% "lat",
  lon      = net_sim %v% "lon"
)

# Edgelist (partnerships). as.edgelist() returns 1-based vertex *indices*, ordered
# (tail, head) for a directed network, so map through id rather than assuming
# index == vertex name.
el    <- as.edgelist(net_sim)
edges <- data.frame(source = attrs$id[el[, 1]],
                    target = attrs$id[el[, 2]])

jsonlite::write_json(
  list(directed   = is.directed(net_sim),
       multigraph = FALSE,
       nodes      = attrs,
       edges      = edges),
  file.path(out_dir, "net_sim.json"),
  auto_unbox = TRUE,   # scalars as 3, not [3]
  digits     = NA)     # full lat/lon precision

cat(sprintf("\nExported %d agents and %d edges to out/net_sim.json (directed=%s)\n",
            nrow(attrs), nrow(edges), is.directed(net_sim)))
