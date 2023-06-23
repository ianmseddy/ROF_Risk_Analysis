#project set up
.user <- Sys.info()[["user"]]
prjDir <- normalizePath(getwd(), winslash = "/")
if (basename(prjDir) != "ROF_Risk_Analysis") {
  stop("please read this file from the .Rproject file")
}

#create a pkgDir outside of the default, to ensure package versions are the same
pkgDir <- file.path(tools::R_user_dir(basename(prjDir), "data"), "packages",
                    version$platform, getRversion()[, 1:2])
pkgDir <- normalizePath(pkgDir, winslash = "/")
if (!dir.exists(pkgDir)){
  dir.create(pkgDir, recursive = TRUE)
}

.libPaths(pkgDir)
if (!require("Require")) install.packages("Require")
library(Require)

makeSnapshot <- TRUE
#this file is a list of all packages and versions used in this repository
if (file.exists("packageVersions.txt")){
  makeSnapshot <- FALSE
  pkgVersions <- Require::Require(packageVersionFile = TRUE, update = FALSE)
}

Require(c("raster", "data.table", "terra", "sf", "googledrive"), libPaths = pkgDir, upgrade = FALSE)
Require("PredictiveEcology/reproducible")
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

options("reproducible.cachePath" = "cache")
