library(rgbif)

key_check <- name_backbone(name = "Pinguicula vulgaris", rank = "species")
taxon_key <- key_check$usageKey  # 5415065, EXACT match, ACCEPTED

download_req <- occ_download(
  pred("taxonKey", taxon_key),
  pred_or(
    pred_within(gb_wkt),
    pred_within(ie_wkt)
  ),
  pred("hasCoordinate", TRUE),
  pred("hasGeospatialIssue", FALSE),
  pred("occurrenceStatus", "PRESENT"),
  format = "SIMPLE_CSV"
)

occ_download_meta(download_req)

# Once processing finishes:
key <- "0021532-260623161305970"
gbif_zip <- occ_download_get(key, path = "data/", overwrite = TRUE)
occurrences <- occ_download_import(gbif_zip)