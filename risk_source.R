###distance to roads 
#Terra doesn't have a cellFromLine function, and griddedDistance does not accept vectors
#I am trying to create a raster with non-empty cells representing lines

#generate a road raster
roads <- vect(file.path(currentData, "Infrastructure/roads/Ontario_Road_Network_(ORN)_Road_NET_Element",
                        "Ontario_Road_Network_(ORN)_Road_Net_Element.shp"))
roads <- terra::project(roads, RTMrast)
roads <- terra::crop(roads, RTMrast)
roads <- terra::buffer(x = roads, width = 50)
roadTemplate <- raster(raster::disaggregate(RTMraster, fact = c(5,5)))
roads <- st_as_sf(roads)  %>%
  st_cast(., "POLYGON")
roads$road <- 1
roadRaster <- fasterize::fasterize(sf = roads, raster = roadTemplate, 
                                   field = "road", background = NA)
writeRaster(roadRaster, "data/rasterized_roads_Ontario.tif", overwrite = TRUE)
roadRaster <- terra::rast("data/rasterized_roads_Ontario.tif")
roadMat <- terra::focalMat(x = roadRaster, d = 1000, type = "circle")
roadDensity <- terra::focal(x = roadRaster, w = roadMat, fun = "sum", na.rm = TRUE)
roadDensity <- terra::aggregate(roadDensity, fact = 5, 
                                fun = "mean")
roadDensity[is.na(roadDensity)] <- 0
roadDensity <- mask(roadDensity, mask = RTMrast, filename = "outputs/roadDensity_50m_Ontario.tif")


classLegend <- data.table(className = c("Other", "cloud/shadow", "clear open water", "turbid water", 
                                        "shoreline", "mudflats", "marsh", "swamp", "fen", "bog", 
                                        "heath", "sparse treed", "treed upland", "deciduous treed",
                                        "mixed treed", "coniferous treed", "plantations - treed cultivated", 
                                        "hedge rows", "disturbance", "cliff and talus", "alvar", 
                                        "sand barren and dune", "open tallgrass prairie", 
                                        "tallgrass savannah", "tallgrass woodland", 
                                        "sand/gravel/mine tailings/extraction", 
                                        "bedrock", "community/infrastructure", 
                                        "agriculture and undifferentiated rural land use"), 
                          class = c(-99, -9, 1:8, 10:28))

#This raster was inside a gdb and I could not find a way to extract it (sf does not work with rasters)
# https://geohub.lio.gov.on.ca/documents/ontario-land-cover-compilation-v-2-0
#it must be downloaded and exported from the file geodatabase
#to my knowledge, no R function can export a raster in a gdb.
lcc <- "data/OLCC_V2_Ontario.tif"
if (file.exists(lcc)){
  lcc <- rast(lcc) 
} else {
  lccraw <- rast("data/OLCC_V2.tif")
  lcc <- terra::project(lccraw, y = RTMrast,
                        method = 'near', mask = TRUE, 
                        filename = lcc, overwrite = TRUE)
}
#terra reclassify is too slow
urbanVals <- terra::values(lcc)
urbLCC <- classLegend[className == "community/infrastructure"]$class
urbanVals[urbanVals != urbLCC] <- 0
urbanVals[urbanVals > 0] <- 1
urbanMat <- terra::focalMat(x = lcc, d = 1000, type = "circle")
urbanDensity <- init(lcc, urbanVals) %>%
  focal(., w = urbanMat, fun = sum, na.rm = TRUE)
urbanDensity <- terra::mask(urbanDensity, RTMrast, 
                            filename = "outputs/urbanDensity_Ontario.tif", 
                            overwrite = TRUE)
rm(urbanVals, urbLCC)

#farming
farmLCC <- classLegend[className == "agriculture and undifferentiated rural land use"]$class
farmVals <- values(lcc)
farmVals[farmVals != farmLCC] <- 0
farmVals[farmVals > 0] <- 1
farmDensity <- init(lcc, farmVals) %>%
  focal(., w = urbanMat, fun = sum, na.rm= TRUE)
farmDensity <- terra::mask(farmDensity, RTMrast, 
                           filename = "outputs/farmDensity_Ontario.tif", 
                           overwrite = TRUE)
rm(farmLCC, urbanMat, farmVals)

#harvest - 
if (!file.exists("data/C2C_harvest_mask_Ontario.tif")) {
  harvest <- prepInputs(url = "https://opendata.nfis.org/downloads/forest_change/CA_forest_harvest_mask_year_1985_2015.zip", 
                        destinationPath = "data", 
                        fun = "raster::stack", 
                        rasterToMatch = RTMrast)
  harvest <- harvest$harvestMask
  write.raster(harvest, "data/C2C_harvest_mask_Ontario.tif")
}



#maybe we do a 1 km focal radius? 
harvestMat <- terra::focalMat(harvest, d = 1000, type = "circle", fillNA = TRUE)
harvestIntensity <- focal(harvest, harvestMat, filename = "outputs/harvestIntensity_1985_2015.tif")
rm(harvestMat, harvest)
# fishing and hunting areas
