# Module 5: networks -> ABM inputs. Export a simulated network as a vertex table
# (agents) and an edgelist (partnerships). The full pipeline exports one edgelist
# per simulated network so network uncertainty carries into the ABM.
if (!exists("net") || !"package:ergm" %in% search()) source(here::here("R", "00-setup.R"))

fit_final_path <- file.path(out_dir, "fit_final.rds")
if (file.exists(fit_final_path)) {
  fit_final <- readRDS(fit_final_path)
} else {
  source(here::here("R", "02-sequential.R"))
}

# One representative simulated network. Save the object so other exporters
# (e.g. R/05-c-alternate.R -> JSON) reformat this SAME network instead of drawing
# their own, which would differ.
net_sim <- simulate(fit_final, nsim = 1)
saveRDS(net_sim, file.path(out_dir, "net_sim.rds"))

# Vertex attribute table (agents)
attrs <- data.frame(
  id       = network.vertex.names(net_sim),
  sex      = net_sim %v% "sex",
  young    = net_sim %v% "young",
  race.num = net_sim %v% "race.num",
  chicago  = net_sim %v% "chicago",
  lat      = net_sim %v% "lat",
  lon      = net_sim %v% "lon"
)
write.csv(attrs, file.path(out_dir, "vertex_attributes.csv"), row.names = FALSE)

# Edgelist (partnerships)
el <- as.edgelist(net_sim)
colnames(el) <- c("from", "to")
write.csv(el, file.path(out_dir, "edgelist.csv"), row.names = FALSE)

cat(sprintf("\nExported %d agents and %d edges to out/\n", nrow(attrs), nrow(el)))

# Ensemble export (optional): one edgelist per simulated network for ABM uncertainty.
# sims <- readRDS(file.path(out_dir, "sims_100.rds"))   # from Module 5
# for (i in seq_along(sims)) {
#   eli <- as.edgelist(sims[[i]]); colnames(eli) <- c("from", "to")
#   write.csv(eli, file.path(out_dir, sprintf("edgelist_%03d.csv", i)), row.names = FALSE)
# }
