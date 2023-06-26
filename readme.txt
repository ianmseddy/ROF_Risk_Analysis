ReadMe

Open this project in Rstudio
Then open the global file (global.R)

Execute the scripts in order to build all the template objects.
You may have to restart Rstudio during package downloading but it should work fine afterward. 

The current study area is the province of Ontario, and a 250-metre raster is used as the template.
All intermediate data is saved to the data folder, and the final results are saved in outputs.
The maps folder contains an .mxd for a multi-panel map, but it assumes the natural breaks layers 
exist in a folder called (outputs/rescaled).
Currently this project does not classify the outputs using natural breaks, though that can be in ArcGIS.
Some raster operations were done at the scale of 50m, to preserve some detail, and then resampled to 250m. 
Much of the data prep uses a 'prepInputs' function that is a one-part function that downloads, reprojects, and writes files. 
It comes from a package called 'reproducible' that must be sourced from GitHub (not CRAN). 


