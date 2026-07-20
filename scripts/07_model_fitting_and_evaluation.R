library(terra)
library(sf)
library(blockCV)
library(pROC)
library(maxnet)

bioclim_final <- rast("output/bioclim_final.tif")
presence_final <- readRDS("output/presence_final.rds")
bg_points <- readRDS("output/bg_points.rds")

presence_final$pa <- 1
bg_points_renamed <- bg_points
names(bg_points_renamed)[names(bg_points_renamed) == "x"] <- "Longitude"
names(bg_points_renamed)[names(bg_points_renamed) == "y"] <- "Latitude"
bg_points_renamed$pa <- 0

model_data <- rbind(presence_final, bg_points_renamed)
model_sf <- st_as_sf(model_data, coords = c("Longitude", "Latitude"), crs = 4326)

bio_vars <- names(bioclim_final)
formula_str <- paste("pa ~", paste(paste0("poly(", bio_vars, ", 2)"), collapse = " + "))

# Baseline GLM fit on all data
sdm_glm <- glm(as.formula(formula_str), data = model_data, family = binomial)
summary(sdm_glm)

# Spatial blocking for  cross-validated (CV) evaluation
autocor_result <- cv_spatial_autocor(r = bioclim_final, num_sample = 5000)

sb <- cv_spatial(
  x = model_sf,
  column = "pa",
  size = autocor_result$range,
  k = 5,
  selection = "random",
  iteration = 50
)

# Spatial CV: GLM
auc_values_glm <- numeric(length(sb$folds_list))
for (k in seq_along(sb$folds_list)) {
  train_idx <- sb$folds_list[[k]][[1]]
  test_idx  <- sb$folds_list[[k]][[2]]
  
  train_data <- model_data[train_idx, ]
  test_data  <- model_data[test_idx, ]
  
  fold_glm <- glm(as.formula(formula_str), data = train_data, family = binomial)
  
  preds <- predict(fold_glm, newdata = test_data, type = "response")
  
  auc_values_glm[k] <- auc(roc(test_data$pa, preds, quiet = TRUE))
}
mean(auc_values_glm)

# Spatial CV: MaxEnt (maxnet)
auc_values_maxnet <- numeric(length(sb$folds_list))
for (k in seq_along(sb$folds_list)) {
  train_idx <- sb$folds_list[[k]][[1]]
  test_idx  <- sb$folds_list[[k]][[2]]
  
  train_data <- model_data[train_idx, ]
  test_data  <- model_data[test_idx, ]
  
  fold_maxnet <- maxnet(p = train_data$pa, data = train_data[, bio_vars])
  
  preds <- predict(fold_maxnet, newdata = test_data[, bio_vars], type = "cloglog")
  
  auc_values_maxnet[k] <- auc(roc(test_data$pa, as.vector(preds), quiet = TRUE))
}
mean(auc_values_maxnet)

saveRDS(list(glm_auc = auc_values_glm, maxnet_auc = auc_values_maxnet), "output/model_evaluation.rds")