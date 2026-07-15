# Pinguicula vulgaris Species Distribution Model

SDM for common butterwort across Scotland, Northern England, and Ireland.

## Status
- [x] Study extent and boundary definitions (`scripts/01_study_extent_and_boundaries.R`)
- [x] GBIF occurrence download (`scripts/02_occurrence_download.R`) — 55,374 records
- GBIF download key: `0021532-260623161305970`
- [x] Environmental predictors: WorldClim bioclim, cropped/masked to study region (`scripts/03_environmental_predictors.R`)
- [x] Occurrence cleaning and spatial thinning (`scripts/04_occurrence_cleaning_and_thinning.R`) — 55,374 raw records → 945 final presence points
- [ ] Predictor collinearity checks
- [ ] Model fitting and evaluation
- [ ] Prediction and mapping

## Reproducibility
`data/` is not tracked — regenerate by running the scripts in order.
Requires a free GBIF account; set `GBIF_USER`, `GBIF_PWD`, `GBIF_EMAIL` in your local `.Renviron` (never committed).