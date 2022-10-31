
options("reproducible.cachePath" = "cache")
options("reproducible.useCache" = TRUE)

#directory structure
checkPath("data", create = TRUE)
checkPath("outputs", create = TRUE)
checkPath("cache", create = TRUE)

#need a study area to bound this stuff 
Canada <- prepInputs(url = "https://www12.statcan.gc.ca/census-recensement/2011/geo/bound-limit/files-fichiers/2016/lpr_000b16a_e.zip", 
                     destinationPath = "data",
                     fun = "st_read")
Ontario <- Canada[Canada$PRENAME == "Ontario",]
if (!file.exists("data/Ontario.shp")) {
  st_write(Ontario, "data/Ontario.shp")
}


studyAreaSF <- st_read("data/Ontario.shp")

biomassFP <- file.path("data/kNN_Biomass_2011.tif")
if (file.exists(biomassFP)) {
  RTMrast <- rast(biomassFP)
  RTMraster <- raster(biomassFP)
} else {
  RTMraster <- prepInputs(url = paste0("http://ftp.maps.canada.ca/pub/nrcan_rncan/Forests_Foret/",
                                       "canada-forests-attributes_attributs-forests-canada/2011-attributes_attributs-2011/",
                                       "NFI_MODIS250m_2011_kNN_Structure_Biomass_TotalLiveAboveGround_v1.tif"),
                          studyArea = OntarioSA,
                          destinationPath = "data", 
                          filename2 = biomassFP)
  RTMrast <- rast(biomassFP)
}
