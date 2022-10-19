#project set up
packageDir <- "packages"
if (!exists(packageDir)) { dir.create(packageDir, showWarnings = FALSE)}

.libPaths(packageDir)
if (!require("Require")) install.packages("Require")
Require("checkpoint")

checkpoint("2021-01-01", r_version = "4.0.2", checkpoint_location = packageDir)

Require(c("raster", "data.table", "terra", "sf"), libPaths = packageDir, upgrade = FALSE)

library(data.table)
library(raster)
library(terra)
library(sf)
library(reproducible)
setDTthreads(2)

