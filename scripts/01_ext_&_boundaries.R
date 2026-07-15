library(sf)
library(terra)
library(geodata)

gb_bbox <- st_bbox(c(xmin = -9, xmax = 1, ymin = 53.5, ymax = 61),
                   crs = st_crs(4326))
ie_bbox <- st_bbox(c(xmin = -11, xmax = -5, ymin = 51, ymax = 55.5),
                   crs = st_crs(4326))

gb_wkt <- st_as_text(st_as_sfc(gb_bbox))
ie_wkt <- st_as_text(st_as_sfc(ie_bbox))

gb_boundary <- gadm(country = "GBR", level = 0, path = "data/")
ie_boundary <- gadm(country = "IRL", level = 0, path = "data/")

imn_boundary <- gadm(country= "IMN",level = 0, path = "data/")
gb_full_boundary <- rbind(gb_boundary, imn_boundary)

gb_mask <- mask(gb_crop, gb_full_boundary)
bioclim_study <- merge(gb_mask, ie_masked)

writeRaster(bioclim_study, "data/bioclim_study.tif", overwrite = TRUE)
