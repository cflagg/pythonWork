# source: http://math.stackexchange.com/questions/143932/calculate-point-given-x-y-angle-and-distance
# http://gamedev.stackexchange.com/questions/18340/get-position-of-point-on-circumference-of-circle-given-an-angle

# Summary: This code pulls together field nitrogen data (with relative coordinates based on azimuth and distance), 
# plot centroids (to give real UTM coordinates), and spectral H5 data (to match up spectra with field nitrogen data by pixel)

# CAVEATS: this currently only works for pointID = 41, since that is the plot center; it wouldn't be difficult to account for 
# other pointIDs but most points are currently at pointID = 41

# Load libraries and functions
library(rhdf5)
library(plyr)
library(dplyr)
library(ggplot2)

radians = function(degrees) {
  rad = (degrees*pi)/180
  return(rad) 	
}

deg = function(radians) {
  degrees = (radians*180)/pi
  return(degrees)
}
############
# initial data set, points all around the origin - two points 180 degrees apart to test visually
rel = data.frame(azimuth = c(0,46.1,250.3,180, 90), distance = c(5.5,10,9.3,17.7, 5))

# calculate x,y coordinates from distance and radians angle
rel$x = with(rel, distance*sin(radians(azimuth)))
rel$y = with(rel, distance*cos(radians(azimuth)))

# plot it out
plot(rel$x,rel$y)
abline(h=0)
abline(v=0)
############

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

# A) Calculate the real positions of the stems, based on plot centroid (pointID=41), azimuth, and distance

# A.1 match up plot center (easting, northing) with a stemID center based on plotID and pointID
# filter rows with Nitrogen data only and point_id == 41 (plot center only)
osbs_n <- field_osbs %>% filter(total_n != 0, point_id == 41) 

# now match up the plot centers with the stemID
osbs_n <- merge(osbs_n, center_osbs, by.x = "plot_id", by.y = "plotID")

# A.2 using the plot center coordinates, calculate the true coordinates of each stem
# calculate x,y coordinates from distance and radians angle -- simply add the plot center coordinates (pointID) to calc new coords
# these coordinates represent the positions of sampled individuals across ALL PLOTS
osbs_n$utm_e = with(osbs_n, stem_distance*sin(radians(stem_azimuth)) + easting)
osbs_n$utm_n = with(osbs_n, stem_distance*cos(radians(stem_azimuth)) + northing)

# calculate the relative x,y coordinates of the stems (from the top-left corner)
# pointID 41 and plot center = (20, 20)
osbs_n$rel_x = with(osbs_n, round(stem_distance*sin(radians(stem_azimuth)) + 20))
osbs_n$rel_y = with(osbs_n, round(stem_distance*cos(radians(stem_azimuth)) + 20))

# plot it out
plot(osbs_n$utm_e, osbs_n$utm_n)
plot(osbs_n$rel_x, osbs_n$rel_y)

# GRAB CANOPY DIMENSIONS TO INFORM SPECTRAL CLIPPING

# store relevant data to pull spectra -- THIS IS A LOOKUP TABLE
flData <- osbs_n %>% select(plotid, point_id, individual_id, utm_e,utm_n, rel_x, rel_y, total_n)

# B) Then bring in the H5 files and pull the spectra for each UTM coordinate -- these might have to be 'translated' as well

head(flData)

# for each plotid, open the h5 file and locate the array section specified by the utm coordinates, clip the data
# grab the spatial info for the plot's boundaries -- this doesn't actually matter! the data were sliced in the same way, 
# so the relative positions from the center work just as well, because they match the dimensions of the array

# list to store reflectance data
clip_ref = list()
for (plot in flData$plotid){
  # browser()
  # open the h5 file for each plotid -- "f" moves the debugger forward one cycle
  ff <-  paste(osbsFiledir, "/", plot,".h5" ,sep="")
  # pull the reflectance data for the specific plotid
  all_ref <- h5read(ff, "Reflectance")
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

# transform into data frame with wavelength data in each column
osbs_ref <- ldply(clip_ref)
# reset the .id column
colnames(osbs_ref)[1] <- "individual_id"

# finally, rejoin with nitrogen and other data, based on individual_id
osbs_out <- merge(osbs_ref, osbs_n, by = "individual_id")


