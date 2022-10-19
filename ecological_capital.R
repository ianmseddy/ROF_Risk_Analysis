#ecological capital 
OntarioSA <- st_as_sf(Ontario)
if (!file.exists(biomass)) {
  biomass <- prepInputs(url = paste0("http://ftp.maps.canada.ca/pub/nrcan_rncan/Forests_Foret/",
                                     "canada-forests-attributes_attributs-forests-canada/2011-attributes_attributs-2011/",
                                     "NFI_MODIS250m_2011_kNN_Structure_Biomass_TotalLiveAboveGround_v1.tif"),
                        studyArea = OntarioSA,
                        destinationPath = "data")
} else {
  biomass <- rast(biomassFP)
}

merchWood <- prepInputs(url = paste0("http://ftp.maps.canada.ca/pub/nrcan_rncan/Forests_Foret/",
                                     "canada-forests-attributes_attributs-forests-canada/2011-attributes_attributs-2011/",
                                     "NFI_MODIS250m_2011_kNN_Structure_Volume_Merch_v1.tif"), 
                        rasterToMatch = RTMraster, 
                        destinationPath = "data")
merchWood <- mask(merchWood, mask = RTMraster, 
                  filename = "outputs/MerchWood_Ontario.tif", 
                  datatype = "INT2U")
#note that the NA value is wrong, 65535

#from https://data.4tu.nl/collections/Carbon_storage_and_distribution_in_terrestrial_ecosystems_of_Canada/5421810/3
#DOI: https://doi.org/10.1016/j.geoderma.2021.115402
#prepInputs is not working - I think the .0.tif is the culprit?
soilC <- paste0("data/16686154/McMaster_WWFCanada_soil_carbon_250m_kg-m2_version3.0/",
                "McMaster_WWFCanada_soil_carbon1m_250m_kg-m2_version3.0.tif")
soilC <- raster(soilC) %>% postProcess(., rasterToMatch = RTMraster, studyArea = studyAreaSF)
writeRaster(soilC, "outputs/SOC_1mDepth_kg-m2_Ontario.tif")

spp <- 
