# The overarching framework is derived from the Wang (2020) manuscript
# ‘Regional ecological risk assessment of multi‑ecosystems under the disturbance of regional pole‑axis syste:
# a case study of the Tongjiang–Fuyuan region, China.’ 
# It is essentially an overlay analysis using 3) categories of data:
# 1) ecological capital, 2) environmental vulnerability, and 3) environmental risk
# using a grid-based representation where each layer is normalized on a 4-point scale.

###set up packages###
source("packages.R")

#build or retrieve study area template and raster
source("template_objects.R")
#the current study area is Ontario, and the template raster is the kNN 2011 above-ground biomass

#build ecological capital files 
source("ecological_capital.R")
#the sources of ecological capital incldue soil carbon, merchantable wood, and aboveground biomass 

source("vulnerability.R")

source("risk_source.R")
