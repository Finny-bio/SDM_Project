library(rgbif)
library(sf)
library(spThin)
library(terra)

key <- "0021532-260623161305970"
gbif_zip <- occ_download_get(key, path = "data/", overwrite = FALSE)
occurrences <- occ_download_import(gbif_zip)

# Coordinate uncertainty filter (~raster resolution, 10km)
uncertainty_threshold <- 10000
occ_filtered <- occurrences[
  is.na(occurrences$coordinateUncertaintyInMeters) |
    occurrences$coordinateUncertaintyInMeters <= uncertainty_threshold,
]

# Drop cultivated specimens, deduplicate exact coordinates
occ_clean <- occ_filtered[occ_filtered$basisOfRecord != "LIVING_SPECIMEN", ]
occ_unique <- occ_clean[!duplicated(occ_clean[, c("decimalLongitude", "decimalLatitude")]), ]

# Convert to sf
occ_sf <- st_as_sf(occ_unique, coords = c("decimalLongitude", "decimalLatitude"), crs = 4326)

# Grid-based pre-thin (one point per raster cell) before the expensive distance-based step
bioclim_study <- rast("data/bioclim_study.tif")

thin_input <- data.frame(
  species = "Pinguicula vulgaris",
  longitude = st_coordinates(occ_sf)[, "X"],
  latitude = st_coordinates(occ_sf)[, "Y"]
)

set.seed(123)
shuffled <- thin_input[sample(nrow(thin_input)), ]
cell_ids <- cellFromXY(bioclim_study, cbind(shuffled$longitude, shuffled$latitude))
pre_thinned <- shuffled[!duplicated(cell_ids), ]

# Proper distance-based spatial thinning (10km, matching raster resolution)
thinned <- thin(
  loc.data = pre_thinned,
  lat.col = "latitude",
  long.col = "longitude",
  spec.col = "species",
  thin.par = 10,
  reps = 100,
  locs.thinned.list.return = TRUE,
  write.files = FALSE,
  verbose = FALSE
)

counts <- sapply(thinned, nrow)
best_index <- which.max(counts)
occ_thinned <- thinned[[best_index]]

saveRDS(occ_thinned, "output/occ_thinned.rds")
