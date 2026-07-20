# Pinguicula vulgaris Species Distribution Model

SDM for common butterwort across Scotland, Northern England, and Ireland.

## Status
- [x] Study extent and boundary definitions (`scripts/01_study_extent_and_boundaries.R`)
- [x] GBIF occurrence download (`scripts/02_occurrence_download.R`) — 55,374 records
  - GBIF download key: `0021532-260623161305970`
- [x] Environmental predictors: WorldClim bioclim, cropped/masked to study region (`scripts/03_environmental_predictors.R`)
- [x] Occurrence cleaning and spatial thinning (`scripts/04_occurrence_cleaning_and_thinning.R`) — 55,374 raw records → 945 final presence points
- [x] Predictor collinearity checks (`scripts/05_predictor_collinearity.R`) — 19 → 7 final predictors (bio_1, bio_3, bio_4, bio_8, bio_9, bio_14, bio_15)
- [x] Model fitting and evaluation (`scripts/06_background_points.R`, `scripts/07_model_fitting_and_evaluation.R`) — GLM and MaxEnt (maxnet) baselines compared via 5-fold spatial block CV; both converge on mean AUC ≈ 0.61, suggesting climate-only predictors impose a real ceiling for this species (likely driven by unmeasured fine-scale hydrology/soil factors)
- [ ] Prediction and mapping

## Reproducibility
`data/` is not tracked — regenerate by running the scripts in order.
Requires a free GBIF account; set `GBIF_USER`, `GBIF_PWD`, `GBIF_EMAIL` in your local `.Renviron` (never committed).
