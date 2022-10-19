#this is climateData::makeMDC but modified to deal with hardcoded filepaths
#(as the data used is from AdaptWest instead of ClimateNA, thus different naming convention)
#additionally I want to calculate MDC normals, instead of annual MDC,
#and finally, the degree variables do not require conversion from tenths of a degree to degree

makeMDC_ROF <- function (inputPath, years = NULL, droughtMonths = 4:9) {
  
  stopifnot(dir.exists(inputPath))
  if (!all(droughtMonths %in% 4:9)) {
    stop("Drought calculation for Months other than April to June is not yet supported")
  }
  variables <- c(paste0("Tmax0", droughtMonths), paste0("PPT0", 
                                                        droughtMonths))
  AllClimateRasters <- lapply(variables, FUN = function(y, 
                                                        Path = inputPath) {
    list.files(path = Path, recursive = TRUE, pattern = paste0("*", 
                                                               y), full.names = TRUE)
  })
  AllClimateRasters <- as.list(sort(unlist(AllClimateRasters)))
  if (length(unlist(AllClimateRasters)) != length(years) * 
      length(variables)) {
    stop("Some files may be missing from:\n  ", inputPath)
  }
  MDCrasters <- lapply(years, FUN = function(year, rasters = AllClimateRasters) {
    grep(pattern = year, x = rasters, 
         value = TRUE)
  })
  MDCstacks <- lapply(MDCrasters, FUN = raster::stack)
  MDCstack <- MDCstacks[[1]]
  # MDCstacks <- lapply(MDCstacks, FUN = function(x) {
  #   tempRasters <- grep(names(x), pattern = "*Tmax")
  #   ppRasters <- grep(names(x), pattern = "*PP")
  #   temp <- x[[names(x)[tempRasters]]]
  #   PPT <- x[[names(x)[ppRasters]]]
  #   temp <- stack(temp)
  #   annualMDCvars <- raster::stack(temp, PPT)
  #   return(annualMDCvars)
  # })
  L_f <- function(Month) {
    c(`4` = 0.9, `5` = 3.8, `6` = 5.8, `7` = 6.4, `8` = 5, 
      `9` = 2.4)[[as.character(Month)]]
  }
  nDays <- function(Month) {
    c(`4` = 30, `5` = 31, `6` = 30, `7` = 31, `8` = 31, 
      `9` = 30)[[as.character(Month)]]
  }
  rm(MDCrasters, AllClimateRasters)
  months <- 4:9
  mdc <- lapply(months, FUN = function(num, MDC = MDCstack) {
    
    ppt <- MDC[[grep(paste0("PPT", "0", num), x = names(MDC))]]
    tmax <- MDC[[grep(paste0("Tmax", "0", num), x = names(MDC))]]
    dt <- data.table(ppt = getValues(ppt), tmax = getValues(tmax), 
                     pixID = 1:ncell(tmax))
    dt <- na.omit(dt)
    dt[, `:=`(mdc_0, 0)]
    dt[, `:=`(mdc_m, as.integer(round(pmax(mdc_0 + 0.25 * 
                                             nDays(num) * (0.36 * tmax + L_f(num)) - 400 * 
                                             log(1 + 3.937 * 0.83 * ppt/(800 * exp(-mdc_0/400))) + 
                                             0.25 * nDays(num) * (0.36 * tmax + L_f(num)), 
                                           0))))]
    mdc <- setValues(tmax, NA)
    mdc[dt$pixID] <- dt$mdc_m
    return(mdc)
  })
  mdc <- raster::stack(mdc)
  annualMDC <- raster::calc(x = mdc, fun = max)
  
  names(annualMDC) <- paste0("mdc", years)
  return(annualMDC)
}
