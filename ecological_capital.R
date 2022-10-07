#ecological capital 

provSpp <- sf::st_read(file.path(currentData, "RoF/Ontario Geohub/PROVTRKG/Non_Sensitive.gdb"), 
                       layer = "PROV_TRK_SPECIES_1KM_GRID")
provDT <- sf::st_read(file.path(currentData, "RoF/Ontario Geohub/PROVTRKG/Non_Sensitive.gdb"), 
                      layer = "PROV_TRK_SPECIES_GRID_DETAIL")
provSpp <- merge(provSpp, provDT, by.x = "OGF_ID", by.y = "PROV_TRK_SPECIES_1KM_GRID_ID")
provSpp1 <- provSpp[!is.na(provSpp$COSEWIC_STATUS),]
rof <- st_transform(rof, crs = st_crs(provSpp1))
provSpp1 <- provSpp1[rof,]
# plot(provSpp1["COSEWIC_STATUS"], key.pos = 2, lwd = 0)
ggplot(provSpp1) + geom_sf(aes(fill = COSEWIC_STATUS), colour = NA) + theme_bw() + 
  geom_sf(data = rof, color = "grey", fill = NA)

#some basic statistics
tempdf <- as.data.table(provSpp1)
tempdf[COSEWIC_STATUS != "NAR", .N, .(COMMON_NAME)]
table(provSpp1$COSEWIC_STATUS)
provSpp1[provSpp1$COSEWIC_STATUS == "END",]$COMMON_NAME

natureCounts <- fread(file.path(currentData, paste0("Wildlife/Ontario/naturecounts_full_obba2be_summ_",
                                                    "1652219045296/naturecounts_data.txt")))
####Biomass from kNN 

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

forestCarbon <- "data/McMaster_WWF_forest_carbon_Ontario.tif"
if (file.exists(forestCarbon)){ 
  forestCarbon <- rast(forestCarbon)
} else {
  carbonData <- rast(file.path(currentData, paste0("carbon/McMaster_WWFCanada_forest_carbon_250m",
                                                   "/McMaster_WWFCanada_forest_carbon_250m_kg-m2",
                                                   "_version1.0.tif")))
  forestCarbon <- reproducible::postProcess(carbonData, rasterToMatch = RTMraster, filename2 = forestCarbon, overwrite = TRUE)
  rm(carbonData)
}


#peatland carbon - use the Hugelius dataset - has depth of peat but also SOC in hectagrams per m2
#histosols are the non-permafrost peatlands
histosolC <- prepInputs(url = "https://bolin.su.se/data/uploads/hugelius-2021-1.zip", 
                      destinationPath = "data", 
                      targetFile = "Histosol_SOC_hg_per_sqm_WGS84.tif",
                      rasterToMatch = RTMraster, 
                      filename2 = "histosol_SOC_hg_sqm_Ontario.tif")
histelC <- prepInputs(url = "https://bolin.su.se/data/uploads/hugelius-2021-1.zip",
                      destinationPath = "data",
                      archive = "Hugelius_etal_2020_PNAS_grids/Grids_TIFF_WGS84.zip",
                      targetFile = "Histel_SOC_hg_per_sqm_WGS84.tif",
                      rasterToMatch = RTMraster,
                      filename2 = "histel_SOC_hg_sqm_Ontario.tif")
# unharvested forest




#wildlife values sites
# 

#water pur
