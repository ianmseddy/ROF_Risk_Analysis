
options("reproducible.cachePath" = "cache")
options("reproducible.useCache" = TRUE)
currentData <- "C:/Ian/data/"

#need a study area to bound this stuff 
Canada <- vect("C:/Ian/Data/Canada/lpr_000b16a_e/lpr_000b16a_e.shp")
Ontario <- Canada[Canada$PRENAME == "Ontario",]
studyArea <- Ontario
studyAreaSF <- sf::st_as_sf(studyArea)
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
