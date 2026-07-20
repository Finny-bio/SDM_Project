library(terra)

bioclim_final <- rast("output/bioclim_final.tif")

set.seed(123)
bg_points <- spatSample(bioclim_final, size = 10000, method = "random", na.rm = TRUE, xy = TRUE)

saveRDS(bg_points, "output/bg_points.rds")