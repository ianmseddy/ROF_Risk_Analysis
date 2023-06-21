# reclassify to natural breaks following Wang 2021
library(magrittr)

vals <- list.files("outputs", pattern = "tif$", full.names = TRUE) %>%
  .[!. %in% c("outputs/DEM_Ontario.tif","outputs/agriculturalLC_Ontario.tif")] %>%
  lapply(., rast)

#this leaves 14 - because there are two MDC and one CMI that would otherwise leave 12 - 4 each
reclassified <- function(rast) {
 vals <- rast[]
 valsNaRM <- vals[!is.na(vals)]
 rm(vals)
 gc()
 #this is horrifically slow - maybe use the sample option?
 breaks <- BAMMtools::getJenksBreaks(valsNaRM, k = 3, subset = 100000)
 return(breaks)
}
NaturalBreaks <-lapply(vals, reclassified)
toname <- unlist(lapply(vals, sources)) %>%
  .[grep(., pattern = "C:/")] %>%
  basename(.)
names(NaturalBreaks) <- toname
names(vals) <- toname

asMat <- lapply(names(NaturalBreaks), 
                FUN = function(x, nb = NaturalBreaks, ras = vals){
  ras <- ras[[x]]
  nb <- nb[[x]]
  vals <- minmax(ras)
  out <- matrix(c(vals[1], nb, nb, vals[2], 1:4), ncol = 3)
  return(out)
})

NBreaksRasters <- Map(terra::classify, x = vals, rcl = asMat)

