###distance to roads 
#Terra doesn't have a cellFromLine function, and griddedDistance does not accept vectors
#I am trying to create a raster with non-empty cells representing lines

#generate a road raster
if (!file.exists("outputs/roadDensity_50m_Ontario.tif")){
  #these were manually downloaded from: # https://geohub.lio.gov.on.ca/datasets/923cb3294384488e8a4ffbeb3b8f6cb2_32/about
  #and https://geohub.lio.gov.on.ca/datasets/lio::mnrf-road-segments/about
  roads <- prepInputs(url = "https://drive.google.com/file/d/1VyQlw4BXkuTU1uCvHA4Ds8qnzWENTszC/view?usp=drive_link",
                      destinationPath = "data", 
                      fun = "terra::vect")
  roads <- project(roads, RTMrast)
  roads <- crop(roads, RTMrast)
  # writeVector(roads, "data/mainRoads.shp")
  roads_mnrf <- prepInputs(url = "https://drive.google.com/file/d/1i-xc7O_fYx7F8XFQhk-Lmf0vS0uokl1O/view?usp=drive_link",
                           destinationPath = "data", 
                           fun = "terra::vect")
  roads_mnrf <- project(roads_mnrf, RTMrast)
  roads_mnrf <- crop(roads_mnrf, RTMrast)
  #the ORN is missing resource roads managed by MNRF - so combine them here
  roadTemplate <- rast(RTMrast)
  roadTemplate <- terra::disagg(roadTemplate, fact = c(5,5))
  #it is immensely faster to combine the rasters than the vectors....
  roads$foo <- 1
  temp <- rasterize(roads, roadTemplate, field = "foo")
  roads_mnrf$foo <- 1
  temp2 <- rasterize(roads_mnrf, roadTemplate, field = "foo")
  
  # roads <- Cache(buffer, x = roads, width = 50, userTags = c("buffer", "roads"))
  # roads_mnrf <- Cache(erase, roads_mnrf, roads) #removes the roads inside the 50m buffer
  # I don't believe this is necessary as the error is generally less than 50m 
  # disappearing when represented as a raster, and this operation is incredibly slow 
  
  #merge them
  roadRaster <- sum(temp, temp2, na.rm = TRUE)
  roadRaster[roadRaster == 2] <- 1
  rm(temp, temp2, roads_mnrf, roadsTemplate, roads)
  
  writeRaster(roadRaster, "data/rasterized_roads_Ontario.tif", overwrite = TRUE)
  roadRaster <- terra::rast("data/rasterized_roads_Ontario.tif")
  roadMat <- terra::focalMat(x = roadRaster, d = 1000, type = "circle")
  roadDensity <- terra::focal(x = roadRaster, w = roadMat, fun = "sum", na.rm = TRUE)
  roadDensity <- terra::aggregate(roadDensity, fact = 5, 
                                  fun = "mean")
  roadDensity[is.na(roadDensity)] <- 0
  roadDensity <- mask(roadDensity, mask = RTMrast, 
                      filename = "outputs/roadDensity_50m_Ontario.tif", overwrite = TRUE)
} else {
  roadDensity <- rast("outputs/roadDensity_50m_Ontario.tif")
}

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

# This raster is inside a gdb and I could not find a way to extract it (sf does not work with rasters)
# https://geohub.lio.gov.on.ca/documents/ontario-land-cover-compilation-v-2-0
# it must be downloaded and exported from the file geodatabase
# terra isn't presently capable of doing this 
lcc <- "data/OLCC_V2_Ontario.tif"
if (file.exists(lcc)){
  lcc <- rast(lcc) 
} else if (file.exists("data/OLCC_V2.tif")) {
  lccraw <- rast("data/OLCC_V2.tif")
  lcc <- terra::project(lccraw, y = RTMrast,
                        method = 'near', mask = TRUE, 
                        filename = lcc, overwrite = TRUE)
  rm(lccraw)
} else {
  stop(paste0("please download the ontario landcover from: ",
              "https://geohub.lio.gov.on.ca/documents/ontario-land-cover-compilation-v-2-0"))
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
                        fun = "terra::rast", 
                        rasterToMatch = RTMrast)
  harvest <- harvest$harvestMask
  writeRaster(harvest, "data/C2C_harvest_mask_Ontario.tif")
}

# 1 km focal radius  
harvestMat <- terra::focalMat(harvest, d = 1000, type = "circle", fillNA = TRUE)
harvestIntensity <- focal(harvest, harvestMat, filename = "outputs/harvestIntensity_1985_2015.tif")
rm(harvestMat, harvest)


