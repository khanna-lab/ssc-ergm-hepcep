# Generates modules/img/hyde-park-map.png for Module 6's "Check it by hand" slide.
#
# Authoring-only. Run it once, commit the PNG, and the deck renders with no
# mapping dependency and no network access. Deliberately uses base R plus `png`
# so nothing needs adding to renv.lock.
#
# Basemap tiles: CARTO Positron. Attribution is drawn onto the image, as their
# terms require.

library(png)

out_png <- file.path("modules", "img", "hyde-park-map.png")

pts <- data.frame(
  id    = c(1, 2, 3),
  label = c("Promontory Point", "Museum of Science\n& Industry",
            "South Shore\nCultural Center"),
  lat   = c(41.796027, 41.790636, 41.768876),
  lon   = c(-87.577310, -87.582482, -87.562375),
  cat   = c(1, 1, 2)
)
ties <- data.frame(from = c(1, 2, 3), to = c(2, 3, 1))   # 1->2, 2->3, 3->1

# Brown SPH palette, matching modules/theme.scss
col_primary <- "#4E3629"; col_navy <- "#003C71"; col_red <- "#ED1C24"

z    <- 15                      # tile zoom
pad  <- 0.12                    # bbox padding, as a fraction of each span
tsz  <- 512                     # @2x tiles are 512 px

# --- Web Mercator, in fractional tile units --------------------------------
lon2x <- function(lon) (lon + 180) / 360 * 2^z
lat2y <- function(lat) {
  r <- lat * pi / 180
  (1 - log(tan(r) + 1 / cos(r)) / pi) / 2 * 2^z
}

xr <- range(lon2x(pts$lon)); yr <- range(lat2y(pts$lat))
xr <- xr + c(-1, 1) * diff(xr) * pad
yr <- yr + c(-1, 1) * diff(yr) * pad

# Widen the narrower axis so the map is not an awkward sliver.
target_aspect <- 1.15                                  # width / height
if (diff(xr) / diff(yr) < target_aspect) {
  need <- diff(yr) * target_aspect
  xr <- mean(xr) + c(-1, 1) * need / 2
}

tx <- floor(xr[1]):floor(xr[2])
ty <- floor(yr[1]):floor(yr[2])
message(sprintf("fetching %d tiles at zoom %d", length(tx) * length(ty), z))

# --- Fetch and stitch -------------------------------------------------------
canvas <- array(1, dim = c(length(ty) * tsz, length(tx) * tsz, 3))
cache  <- file.path(tempdir(), "tiles"); dir.create(cache, showWarnings = FALSE)

for (i in seq_along(tx)) for (j in seq_along(ty)) {
  url <- sprintf("https://basemaps.cartocdn.com/light_all/%d/%d/%d@2x.png",
                 z, tx[i], ty[j])
  dst <- file.path(cache, sprintf("%d_%d_%d.png", z, tx[i], ty[j]))
  if (!file.exists(dst)) {
    utils::download.file(url, dst, mode = "wb", quiet = TRUE,
                         headers = c(`User-Agent` = "ssc-ergm-hepcep/1.0"))
  }
  tile <- readPNG(dst)
  if (length(dim(tile)) == 2) tile <- array(tile, dim = c(dim(tile), 3))
  rows <- ((j - 1) * tsz + 1):(j * tsz)
  cols <- ((i - 1) * tsz + 1):(i * tsz)
  canvas[rows, cols, ] <- tile[, , 1:3]
}

# Extent of the stitched canvas, in tile units
cx <- c(min(tx), max(tx) + 1)
cy <- c(min(ty), max(ty) + 1)

# --- Draw -------------------------------------------------------------------
px_w <- 900
px_h <- round(px_w * diff(yr) / diff(xr))
png(out_png, width = px_w, height = px_h, res = 150, type = "quartz")
par(mar = c(0, 0, 0, 0), xaxs = "i", yaxs = "i")
plot.new()
plot.window(xlim = xr, ylim = rev(yr), asp = 1)        # y increases southward

rasterImage(canvas, cx[1], cy[2], cx[2], cy[1], interpolate = TRUE)

X <- lon2x(pts$lon); Y <- lat2y(pts$lat)

# Ties, drawn short of each node so the arrowheads stay clear
for (k in seq_len(nrow(ties))) {
  a <- ties$from[k]; b <- ties$to[k]
  dx <- X[b] - X[a]; dy <- Y[b] - Y[a]; L <- sqrt(dx^2 + dy^2)
  gap <- diff(xr) * 0.016
  arrows(X[a] + dx / L * gap, Y[a] + dy / L * gap,
         X[b] - dx / L * gap * 1.35, Y[b] - dy / L * gap * 1.35,
         length = 0.10, angle = 22, lwd = 2.6, col = col_primary)
}

points(X, Y, pch = 21, cex = 2.5, lwd = 1.6,
       bg = ifelse(pts$cat == 1, col_navy, col_red), col = "white")
text(X, Y, pts$id, col = "white", font = 2, cex = 0.72)

# Labels, nudged away from the node and kept inside the frame
label_pos <- c(4, 2, 4)
text(X, Y, labels = pts$label, pos = label_pos, offset = 0.75,
     cex = 0.80, font = 2, col = col_primary)

# Title plate, so the map says where it is without leaning on the slide text
plate <- function(x, y, w, h) rect(x, y, x + w, y + h, col = "#ffffffcc", border = NA)
plate(xr[1] + diff(xr) * 0.015, yr[1] + diff(yr) * 0.015,
      diff(xr) * 0.34, diff(yr) * 0.055)
text(xr[1] + diff(xr) * 0.032, yr[1] + diff(yr) * 0.048, "Hyde Park, Chicago",
     adj = c(0, 0.5), cex = 0.95, font = 2, col = col_primary)

# Scale bar. One tile spans 40075016.686 / 2^z metres at the equator.
m_per_tile <- 40075016.686 / 2^z * cos(mean(pts$lat) * pi / 180)
km_in_tiles <- 1000 / m_per_tile
sb_x <- xr[1] + diff(xr) * 0.05
sb_y <- yr[2] - diff(yr) * 0.055
plate(xr[1] + diff(xr) * 0.015, yr[2] - diff(yr) * 0.10,
      km_in_tiles + diff(xr) * 0.07, diff(yr) * 0.085)
segments(sb_x, sb_y, sb_x + km_in_tiles, sb_y, lwd = 3, col = col_primary)
segments(c(sb_x, sb_x + km_in_tiles), sb_y - diff(yr) * 0.012,
         c(sb_x, sb_x + km_in_tiles), sb_y + diff(yr) * 0.012,
         lwd = 3, col = col_primary)
text(sb_x + km_in_tiles / 2, sb_y - diff(yr) * 0.035, "1 km",
     cex = 0.72, font = 2, col = col_primary)

# Attribution, required by CARTO and OSM
text(xr[2] - diff(xr) * 0.01, yr[2] - diff(yr) * 0.015,
     "© OpenStreetMap contributors © CARTO",
     adj = c(1, 0), cex = 0.52, col = "#5a5a5a")

invisible(dev.off())

# A basemap uses few distinct colours, so a 128-colour palette is visually
# indistinguishable and roughly a third of the size. Skipped if ImageMagick is
# absent, which only costs file size.
if (nzchar(Sys.which("magick"))) {
  before <- file.size(out_png)
  system2("magick", c(shQuote(out_png), "-colors", "128", "-strip",
                      shQuote(out_png)))
  message(sprintf("quantised: %.0f KB -> %.0f KB",
                  before / 1024, file.size(out_png) / 1024))
}

message("wrote ", out_png)
