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
jercFiledir <- paste(filedir, "/h5_JERC", sep="")
# list the files
jerc_list <- list.files(jercFiledir)
# wavelength file
wavelengths <-read.csv("C:/Users/cflagg/Documents/GitHub/pythonWork/pls/wavelengths_um.csv")
# output files
outdir <- "C:/Users/cflagg/Documents/GitHub/pythonWork/pls"

##### Load Field data and GPS data
# field dat
field_jerc <- read.csv("C:/Users/cflagg/Documents/GitHub/pythonWork/pls/JERC_2014_foliarChem_vegStr.csv")
# plot centroids
center_jerc <- read.csv("C:/Users/cflagg/Documents/GitHub/pythonWork/pls/JERC_center.csv")

# A) Calculate the real positions of the stems, based on plot centroid (pointID=41), azimuth, and distance

# A.1 match up plot center (easting, northing) with a stemID center based on plotID and pointID
# filter rows with Nitrogen data only and point_id == 41 (plot center only)
jerc_n <- field_jerc %>% filter(total_n > 0, point_id == 41) 

# now match up the plot centers with the stemID
jerc_n <- merge(jerc_n, center_jerc, by.x = "plot_id", by.y = "plot_id")

# A.2 using the plot center coordinates, calculate the true coordinates of each stem
# calculate x,y coordinates from distance and radians angle -- simply add the plot center coordinates (pointID) to calc new coords
# these coordinates represent the positions of sampled individuals across ALL PLOTS
jerc_n$utm_e = with(jerc_n, stem_distance*sin(radians(stem_azimuth)) + easting)
jerc_n$utm_n = with(jerc_n, stem_distance*cos(radians(stem_azimuth)) + northing)

# calculate the relative x,y coordinates of the stems (from the top-left corner)
# pointID 41 and plot center = (20, 20)
jerc_n$rel_x = with(jerc_n, round(stem_distance*sin(radians(stem_azimuth)) + 20))
jerc_n$rel_y = with(jerc_n, round(stem_distance*cos(radians(stem_azimuth)) + 20))

# plot it out
plot(jerc_n$utm_e, jerc_n$utm_n)
plot(jerc_n$rel_x, jerc_n$rel_y)

# GRAB CANOPY DIMENSIONS TO INFORM SPECTRAL CLIPPING

# store relevant data to pull spectra -- THIS IS A LOOKUP TABLE
flData <- jerc_n %>% select(plot_id, point_id, individual_id, utm_e,utm_n, rel_x, rel_y, total_n)

# B) Then bring in the H5 files and pull the spectra for each UTM coordinate -- these might have to be 'translated' as well

head(flData)

# for each plotid, open the h5 file and locate the array section specified by the utm coordinates, clip the data
# grab the spatial info for the plot's boundaries -- this doesn't actually matter! the data were sliced in the same way, 
# so the relative positions from the center work just as well, because they match the dimensions of the array

# list to store reflectance data
clip_ref = list()
for (plot in flData$plot_id){
  # browser()
  # open the h5 file for each plotid -- "f" moves the debugger forward one cycle
  ff <-  paste(jercFiledir, "/", plot,".h5" ,sep="")
  # pull the reflectance data for the specific plotid
  all_ref <- h5read(ff, "Reflectance")
  # pass part of the data frame on to the next loop
  d <- flData[flData$plot_id == plot,] 
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
jerc_ref <- ldply(clip_ref)
# reset the .id column
colnames(jerc_ref)[1] <- "individual_id"

# finally, rejoin with nitrogen and other data, based on individual_id
jerc_out <- merge(jerc_ref, jerc_n, by = "individual_id")

# write out the file
write.csv(jerc_out, paste(outdir,"/jerc_n_ref.csv", sep=""))

