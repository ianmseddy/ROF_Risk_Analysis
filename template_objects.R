require("Require")
Require(c("data.table", "terra", "sf", "ggplot2", 'reproducible', "raster"))
options("reproducible.cachePath" = "cache")
currentData <- "C:/Ian/data/"

#need a study area to bound this stuff 
Canada <- vect("C:/Ian/Data/Canada/lpr_000b16a_e/lpr_000b16a_e.shp")
Ontario <- Canada[Canada$PRENAME == "Ontario",]
studyArea <- Ontario
biomassFP <- file.path("data/kNN_Biomass_2011.tif")
RTMrast <- rast(biomassFP)
RTMraster <- raster(biomassFP)

###distance to roads 
#Terra doesn't have a cellFromLine function, and griddedDistance does not accept vectors
#I am trying to create a raster with non-empty cells representing lines

#generate a road raster

# writeRaster(roadDistance, filename = "outputs/distance_To_MNRF_roads.tif")


#where does vulnerability originate? 
#originally slope, NDVI, soil erodibility, and management vulnerability
# we could use stream position, habitat feature 




