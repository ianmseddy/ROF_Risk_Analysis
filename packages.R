#project set up
.user <- Sys.info()[["user"]]
prjDir <- normalizePath(getwd(), winslash = "/")
if (basename(prjDir) != "ROF_Risk_Analysis") {
  stop("please read this file from the .Rproject file")
}

#create a pkgDir outside of the default, to ensure package versions are the same
pkgDir <- file.path(tools::R_user_dir(basename(prjDir), "data"), "packages",
                    version$platform, getRversion()[, 1:2])

useSnapshot <- FALSE
makeSnapshot <- FALSE
pkgDir <- normalizePath(pkgDir, winslash = "/")
if (!dir.exists(pkgDir)){
  dir.create(pkgDir, recursive = TRUE)
  useSnapshot <- TRUE
}

.libPaths(pkgDir)
if (!require("Require")) install.packages("Require")
library(Require)

#this file is a list of all packages and versions used in this repository
if (file.exists("packageVersions.txt")){
  if (useSnapshot){
    pkgVersions <- Require::Require(packageVersionFile = TRUE, update = FALSE)
  }
} else {
 makeSnapshot <- TRUE
}
#this should install all packages if missing (and if a package snapshot is provided)
# it wil make the package snapshot if absent. 

Require(c("raster", "data.table", "terra", "sf", "googledrive"), libPaths = pkgDir, upgrade = FALSE)
Require("PredictiveEcology/reproducible", upgrade = FALSE)
Require("magrittr")

library(data.table)
library(raster)
library(terra)
library(sf)
library(reproducible)
library(googledrive)
setDTthreads(2)
options("reproducible.useTerra" = TRUE)
if (makeSnapshot){
  Require::pkgSnapshot()
}
rm(makeSnapshot, useSnapshot)

options("reproducible.cachePath" = "cache")
setDTthreads(2)
