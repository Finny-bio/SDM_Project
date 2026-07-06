library(terra)
library(geodata)

# Requires gb_bbox, ie_bbox, gb_boundary, ie_boundary from script 01

bioclim_global <- worldclim_global(var = "bio", res = 5, path = "data/")

gb_crop <- crop(bioclim_global, ext(gb_bbox["xmin"], gb_bbox["xmax"], gb_bbox["ymin"], gb_bbox["ymax"]))
ie_crop <- crop(bioclim_global, ext(ie_bbox["xmin"], ie_bbox["xmax"], ie_bbox["ymin"], ie_bbox["ymax"]))

gb_masked <- mask(gb_crop, gb_boundary)
ie_masked <- mask(ie_crop, ie_boundary)

bioclim_study <- merge(gb_masked, ie_masked)

writeRaster(bioclim_study, "data/bioclim_study.tif", overwrite = TRUE)