#ecological capital 
if (!file.exists(biomass)) {
  biomass <- prepInputs(url = paste0("http://ftp.maps.canada.ca/pub/nrcan_rncan/Forests_Foret/",
                                     "canada-forests-attributes_attributs-forests-canada/2011-attributes_attributs-2011/",
                                     "NFI_MODIS250m_2011_kNN_Structure_Biomass_TotalLiveAboveGround_v1.tif"),
                        studyArea = Ontario,
                        destinationPath = "data")
} else {
  biomass <- rast(biomassFP)
}

merchWood <- prepInputs(url = paste0("http://ftp.maps.canada.ca/pub/nrcan_rncan/Forests_Foret/",
                                     "canada-forests-attributes_attributs-forests-canada/2011-attributes_attributs-2011/",
                                     "NFI_MODIS250m_2011_kNN_Structure_Volume_Merch_v1.tif"), 
                        rasterToMatch = RTMraster, 
                        destinationPath = "data")
merchWood[merchWood < 0] <- 0
#nonforest should read 0 
merchWood <- mask(merchWood, mask = RTMraster,
                  filename = "outputs/MerchWood_Ontario.tif", 
                  overwrite = TRUE)

#note that the NA value is wrong, 65535

#from https://data.4tu.nl/collections/Carbon_storage_and_distribution_in_terrestrial_ecosystems_of_Canada/5421810/3
#DOI: https://doi.org/10.1016/j.geoderma.2021.115402
#due to the name of this file, it cannot be sourced with prepInputs
#specifically the '3.0' as the period as interpreted as a file format
# "https://data.4tu.nl/datasets/56df7498-d88e-47ae-8292-f5cf86a6a2f9"
# the file has been re-hosted on Google Drive
soilC <- prepInputs(url = "https://drive.google.com/file/d/1gMxDj12QHfwKbKsJBu9PXboydCBQ3pCM/view?usp=drive_link", 
                    targetFile = "McMaster_WWFCanada_soil_carbon1m_250m_kg-m2_version3.0.tif",
                    rasterToMatch = RTMrast,
                    studyArea = Ontario,
                    fun = "terra::rast",
                    destinationPath = "data", 
                    overwrite = TRUE,
                    filename2 = "outputs/SOC_1mDepth_km-m2_Ontario.tif")

#soil agricultural potential - this dataset is incomplete and so not very useful
# https://geohub.lio.gov.on.ca/datasets/ontarioca11::soil-survey-complex/about
soilSurvey <- prepInputs(url = "https://www.gisapplication.lrc.gov.on.ca/fmedatadownload/Packages/SOILOMAF.zip",
                         destinationPath = "data", 
                         fun = "st_read")
soilSurvey <- st_transform(soilSurvey, crs = crs(RTMraster))
#reclassify organic to 0 
soilSurvey$CLI1r <- soilSurvey$CLI1
soilSurvey$CLI1r[soilSurvey$CLI1r %in% c("W", "O")] <- 0
soilSurvey$CLI1r <- as.numeric(soilSurvey$CLI1r)
#2 
soilSurvey$CLI2r <- soilSurvey$CLI2
soilSurvey$CLI2r[soilSurvey$CLI2r %in% c("W", "O")] <- 0
soilSurvey$CLI2r <- as.numeric(soilSurvey$CLI2r)
#3
soilSurvey$CLI3r <- soilSurvey$CLI3
soilSurvey$CLI3r[soilSurvey$CLI3r %in% c("W", "O")] <- 0
soilSurvey$CLI3r <- as.numeric(soilSurvey$CLI3r)

tempDT <- as.data.table(soilSurvey)
tempDT <- tempDT[, .(sum1 = PERCENT1 * CLI1r,
                     sum2 = PERCENT2 * CLI2r,
                     sum3 = PERCENT3 * CLI3r)] #when percent is 0 it will evaluate to NA
tempDT <- tempDT[, names(tempDT) := lapply(.SD, nafill, fill = 0)]
tempDT[, weightedReclass := sum1 + sum2 + sum3]
soilSurvey$weightedSoilClass <- tempDT$weightedReclass
soilSurveyRas <- rasterize(soilSurvey, RTMrast, field = "weightedSoilClass")
soilSurveyRas <- mask(soilSurveyRas, RTMraster, filename = "outputs/weightedSoilSurveyComplex.tif", 
                      overwrite = TRUE)


