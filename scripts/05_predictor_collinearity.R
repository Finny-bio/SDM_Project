library(terra)
library(usdm)

bioclim_study <- rast("data/bioclim_study.tif")
occ_thinned <- readRDS("output/occ_thinned.rds")

presence_env <- extract(bioclim_study, occ_thinned[, c("Longitude", "Latitude")])
presence_data <- cbind(occ_thinned[, c("Longitude", "Latitude")], presence_env[, -1])

bio_cols <- grep("^wc2.1_5m_bio_", names(presence_data), value = TRUE)
vif_result <- vifstep(presence_data[, bio_cols], th = 10)
vif_result

retained_vars <- as.character(vif_result@results$Variables)

bioclim_final <- bioclim_study[[retained_vars]]
writeRaster(bioclim_final, "output/bioclim_final.tif", overwrite = TRUE)

presence_final <- presence_data[, c("Longitude", "Latitude", retained_vars)]
saveRDS(presence_final, "output/presence_final.rds")