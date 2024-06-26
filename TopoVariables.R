##### Topography Variables ##########################################################################
# Author: Sarah Hettema
# Created: 6/13/2024
# Uses USGS DEM downloaded from GEE to derive Slope, Topographic Position Index, 
# Topographic wetness Index, Aspect, Terrain Roughness, and Heat Load Index
# Outputs: TIFs of all topo variables written to interim_data > predictors > 
#          Topography
#############################################################################################################

# Read in Packages 
library(terra)
library(dplyr)
library(spatialEco)
library(whitebox)

# Set parent directory  
parent_directory <- "C:/Users/shettema/OneDrive - Colostate/Desktop/WTO/Data/"

# Read in USGS DEM
DEM_fp <- paste0(parent_directory, "Original_Data/predictors/Topography/USGS_DEM_clip.tif")
DEM <- rast(DEM_path)
plot(DEM)

the.prj = crs('epsg:26913')

DEM <- DEM %>%
  project(., the.prj)

slope <- terrain(DEM, "slope")
TPI <- terrain(DEM, "TPI")
aspect <- terrain(DEM, "aspect")
roughness <- terrain(DEM, "roughness")
# plot(roughtness)

HLI <- hli(DEM)

# ###### Uncomment to write raster 
# writeRaster(HLI, paste0(parent_directory, "interim_data/predictors/Topography/HLI.tif"))


##### Use Whitebox to derive TWI 
# Calculate intermediate layers
# Process DEM for Analysis
breach_fp <- paste0(parent_directory, "interim_data/predictors/Topography/wbt_breached.tif")
wbt_breach_depressions_least_cost(
  dem = DEM_fp,
  output = breach_fp,
  dist = 30,
  fill = TRUE)

filled_breach_fp <- paste0(parent_directory, "interim_data/predictors/Topography/wbt_filled_breached.tif")
wbt_fill_depressions_wang_and_liu(
  dem = breach_fp,
  output = filled_breach_fp
)

# Flow Accumulation/ Specific Contributing Area (SCA)
flow_fp <- paste0(parent_directory, "interim_data/predictors/Topography/wbt_inf_flow_accumulation.tif")
wbt_d_inf_flow_accumulation(input = DEM_fp, # filled_breach_fp
                            output = flow_fp, 
                            out_type = "Specific Contributing Area")
# Calculate Slope
slope_fp <- paste0(parent_directory, "interim_data/predictors/Topography/wbt_slope.tif")
wbt_slope(dem = DEM_fp, #filled_breach_fp
          output = slope_fp, 
          units = "degrees")

###### Calculate TWI
TWI_fp <- paste0(parent_directory, "interim_data/predictors/Topography/wbt_wetness_index.tif")
wbt_wetness_index(sca = flow_fp,
                  slope = slope_fp,
                  output = TWI_fp)

# Visual Check
wbt_dem <- rast(filled_breach_fp)
TWI <- rast(TWI_fp)
plot(TWI)

