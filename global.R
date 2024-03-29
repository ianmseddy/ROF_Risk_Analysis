# The overarching framework is derived from the Wang (2021) manuscript
# ‘Regional ecological risk assessment of multi‑ecosystems under the disturbance of regional pole‑axis syste:
# a case study of the Tongjiang–Fuyuan region, China.’ 
# It is essentially an overlay analysis using 3) categories of data:
# 1) ecological capital, 2) environmental vulnerability, and 3) environmental risk
# using a grid-based representation where each layer is normalized on a 4-point scale.

####set up packages####
source("packages.R")

# build or retrieve study area template and raster
source("template_objects.R")
# the current study area is Ontario, and the template raster is the kNN 2011 above-ground biomass

# build ecological capital files 
source("ecological_capital.R")
# the sources of ecological capital incldue soil carbon, merchantable wood, and aboveground biomass 
source("vulnerability.R")
# the sources of vulnerability include projected increases in drought, change in climate moisture index,
# and areas projected to be climate refugia for birds and trees
source("risk_source.R")
# the sources of risk include areas with higher density of roads, timber harvest, farmland, 
# and urban development, due to presumed increaes in pollutants, fire risk, wildlife conflict, etc

# following Wang et al. 2021, classify the outputs using Jenk's Natural Breaks. 
# this can be done using rgeoda or in ArcMap with the classify function. 
# The two approaches do not achieve the same result - evidently there is some subsampling involved
# I suspect rgeoda is internally sampling as it is much faster. 
# I tried alternatives like BAMMtools::getJenksBreaks but it is extremely slow

filesToZip <- list.files("outputs", recursive = TRUE, full.names = TRUE, pattern = ".tif$")
utils::zip(zipfile = "allOutputs.zip", files = filesToZip)
