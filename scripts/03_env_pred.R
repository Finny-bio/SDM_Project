library(terra)
library(geodata)

# Requires gb_bbox, ie_bbox, gb_boundary, ie_boundary, imn_boundary from script 01

bioclim_global <- worldclim_global(var = "bio", res = 5, path = "data/")

gb_crop <- crop(bioclim_global, ext(gb_bbox["xmin"], gb_bbox["xmax"], gb_bbox["ymin"], gb_bbox["ymax"]))
ie_crop <- crop(bioclim_global, ext(ie_bbox["xmin"], ie_bbox["xmax"], ie_bbox["ymin"], ie_bbox["ymax"]))

# Only mask by country boundary within the region where the GB and Ireland
# boxes genuinely overlap (Northern Ireland / Donegal). Elsewhere, WorldClim's
# own land/sea NA structure is already correct, and GADM's simplified boundaries
# would incorrectly strip out small islands (Hebrides, Isle of Man, etc.)
gb_full_boundary <- rbind(gb_boundary, imn_boundary)

overlap_xmin <- max(gb_bbox["xmin"], ie_bbox["xmin"])
overlap_xmax <- min(gb_bbox["xmax"], ie_bbox["xmax"])
overlap_ymin <- max(gb_bbox["ymin"], ie_bbox["ymin"])
overlap_ymax <- min(gb_bbox["ymax"], ie_bbox["ymax"])
overlap_ext <- ext(overlap_xmin, overlap_xmax, overlap_ymin, overlap_ymax)

gb_overlap <- crop(gb_crop, overlap_ext)
ie_overlap <- crop(ie_crop, overlap_ext)

gb_overlap_masked <- mask(gb_overlap, gb_full_boundary)
ie_overlap_masked <- mask(ie_overlap, ie_boundary)

overlap_resolved <- merge(gb_overlap_masked, ie_overlap_masked)
bioclim_study <- merge(overlap_resolved, gb_crop, ie_crop)

# Fill small coastal NA gaps (e.g. presence points whose rounded 1km-grid
# coordinate falls just offshore) using immediate valid neighbours only
bioclim_study <- focal(bioclim_study, w = 3, fun = "mean", na.policy = "only", na.rm = TRUE)

writeRaster(bioclim_study, "data/bioclim_study.tif", overwrite = TRUE)