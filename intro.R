#project set up
packageDir <- "packages"
if (!exists(packageDir)) dir.create(packageDir)

.libPaths(packageDir)
if (!require("Require")) install.packages("Require")
Require("checkpoint")
checkpoint("2021-01-01", r_version = "4.0.2", checkpoint_location = packageDir)

Require(c("data.table", "terra", "sf", "ggplot2"))

