###distance to roads 
#Terra doesn't have a cellFromLine function, and griddedDistance does not accept vectors
#I am trying to create a raster with non-empty cells representing lines

#generate a road raster
if (!file.exists("outputs/distance_to_roads.tif")) {
  roads <- vect(file.path(currentData, "Infrastructure/roads/Ontario_Road_Network_(ORN)_Road_NET_Element",
                          "Ontario_Road_Network_(ORN)_Road_Net_Element.shp"))
  roads <- project(roads, RTMrast)
  roads <- crop(roads, RTMrast)
  roads <- buffer(x = roads, width = 250)
  roadTemplate <- raster::raster(RTMraster)
  roads <- st_as_sf(roads)  %>%
    st_cast(., "POLYGON")
  roads$road <- 1
  roadRaster <- fasterize::fasterize(sf = roads, raster = roadTemplate, 
                                     field = "road", background = NA)
  roadRaster <- terra::rast(roadRaster)
  roadRaster <- reproducible::Cache(gridDistance, temp, userTags = c("gridDistance")) 
  roadDistance <- mask(roadRaster, Ontario, filename = "outputs/distance_to_roads.tif")
  rm(test, temp)
} else {
  roadDistance <- rast("outputs/distance_to_roads.tif")
}
# writeRaster(roadDistance, filename = "outputs/distance_To_MNRF_roads.tif")
#this raster is in a gdb, and I do not know a way to read a raster from gdb (sf expects vector)
#I can extract it but not through prepInputs. Fix later
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
classLegend
lcc <- "data/OLCC_V2_Ontario.tif"
if (file.exists(lcc)){
  lcc <- rast(lcc) 
} else {
  lccraw <- rast("data/OLCC_V2.tif")
  lcc <- terra::project(lccraw, y = RTMrast,
                        method = 'near', mask = TRUE, 
                        filename = lcc, overwrite = TRUE)
}

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
harvestIntensity <- focal(harvest, harvestMat, filename = "data/harvestIntensity_1985_2015.tif")
rm(harvestMat, harvest)
# fishing and hunting areas


