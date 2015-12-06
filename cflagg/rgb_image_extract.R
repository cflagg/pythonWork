## Extracting spectral data for RGB images of each plot

# Load libraries and functions
library(rhdf5)
library(plyr)
library(dplyr)
library(ggplot2)
library(raster)
library(rgdal)

##### List H5 files in appropriate directory
# set the base path to h5 files
filedir <- "C:/Users/cflagg/Documents/GitHub/pythonWork/canopyN/data/processed"
# set a more specific path to site
osbsFiledir <- paste(filedir, "/h5_OSBS", sep="")
# list the files
osbs_list <- list.files(osbsFiledir)
# wavelength file
wavelengths <-read.csv("C:/Users/cflagg/Documents/GitHub/pythonWork/pls/wavelengths_um.csv")

##### Load Field data and GPS data
# field dat
field_osbs <- read.csv("C:/Users/cflagg/Documents/GitHub/pythonWork/pls/OSBS_2014_foliarChem_vegStr.csv")
# plot centroids
center_osbs <- read.csv("C:/Users/cflagg/Documents/GitHub/pythonWork/pls/OSBS_center.csv")


# list to store reflectance data
clip_ref = list()
for (plot in flData$plotid){
  # browser()
  # open the h5 file for each plotid -- "f" moves the debugger forward one cycle
  ff <-  paste(osbsFiledir, "/", plot,".h5" ,sep="")
  # pull the reflectance data for the specific plotid
  all_ref <- h5read(ff, "Reflectance")
  sp_info <- h5read(ff,"plotBoundaries")
  # pass part of the data frame on to the next loop
  d <- flData[flData$plotid == plot,] 
  # make sure the correct h5 file is being grabbed
  print(paste(plot, ff))
  # for each plotid, grab the individualID's relative coordinates
  for (stem in d$individual_id){
    print(stem)
    # for each individual stem, pull the coordinate information
    stemInfo <- d[which(d$individual_id == stem),]
    print(paste(stemInfo$rel_x, stemInfo$rel_y))
    # take the coordinates, slice the array, and store it
    # all_ref[stemInfo$rel_x, stemInfo$rel_y, 1:426] -- lists are indexed with double brackets "list[[]]"
    clip_ref[[stem]] <- all_ref[stemInfo$rel_x, stemInfo$rel_y, 1:426]
  }}

# spatial info for each HDF5 file 
# utm coordinates = leftx, rightx, topy, bottomy 
# should check this to verify that the boundary is not 'rotated' before I extract the single pixel
# 1) grab the spatial info
# 2) convert the pixel's relative location to UTM coordinates

# turn value = 15000 into NA
all_ref[all_ref == 15000] <- NA

# slice out rgb bands from the individual h5 file -- convert to raster class
b1 <- all_ref[,,19]; b1 <- raster(b1)
g1 <- all_ref[,,34]; g1 <- raster(g1)
r1 <- all_ref[,,90]; r1 <- raster(r1)

# put rasters in a list
rast <- list(r1,g1,b1)

# create an RGB image stack
rast_stack <- stack(rast)

# plot raster stack 
plotRGB(rast_stack, r=1, g=2,b=3, scale = 10000, stretch = "Lin", interpolate = TRUE)

image(log(rast_stack$layer.1), col=terrain.colors(25))
