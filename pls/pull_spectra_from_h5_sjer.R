# source: http://math.stackexchange.com/questions/143932/calculate-point-given-x-y-angle-and-distance
# http://gamedev.stackexchange.com/questions/18340/get-position-of-point-on-circumference-of-circle-given-an-angle

# Summary: This code pulls together field nitrogen data (with relative coordinates based on azimuth and distance), 
# plot centroids (to give real UTM coordinates), and spectral H5 data (to match up spectra with field nitrogen data by pixel)

# CAVEATS: this currently only works for pointID = 41, since that is the plot center; it wouldn't be difficult to account for 
# other pointIDs but most points are currently at pointID = 41

## THE INPUT FILES ALSO CONTAIN DATA FOR SOAP, HENCE WHY NROW() DECREASES WITH SUBSEQUENT MERGES

# Load libraries and functions
library(rhdf5)
library(plyr)
library(dplyr)
library(ggplot2)
library(stringr)

radians = function(degrees) {
  rad = (degrees*pi)/180
  return(rad) 	
}

deg = function(radians) {
  degrees = (radians*180)/pi
  return(degrees)
}
############
# # initial data set, points all around the origin - two points 180 degrees apart to test visually
# rel = data.frame(azimuth = c(0,46.1,250.3,180, 90), distance = c(5.5,10,9.3,17.7, 5))
# 
# # calculate x,y coordinates from distance and radians angle
# rel$x = with(rel, distance*sin(radians(azimuth)))
# rel$y = with(rel, distance*cos(radians(azimuth)))
# 
# # plot it out
# plot(rel$x,rel$y)
# abline(h=0)
# abline(v=0)
# ############

##### List H5 files in appropriate directory
# set the base path to h5 files
filedir <- "C:/Users/cflagg/Documents/GitHub/pythonWork/canopyN/data/processed"
# set a more specific path to site
SJERFiledir <- paste(filedir, "/h5_SJER", sep="")
# list the files
SJER_list <- list.files(SJERFiledir)
# wavelength file
wavelengths <-read.csv("C:/Users/cflagg/Documents/GitHub/pythonWork/pls/wavelengths_um.csv")
# output files
outdir <- "C:/Users/cflagg/Documents/GitHub/pythonWork/pls"

##### Load Field data and GPS data
# field dat
foliar_SJER <- read.csv("C:/Users/cflagg/Documents/GitHub/pythonWork/pls/SJER_2013_foliarChem.csv")
foliar_SJER$individualID <- str_sub(foliar_SJER$Individual, start = 2, end = 4)
vst_SJER <- read.csv("C:/Users/cflagg/Documents/GitHub/pythonWork/pls/SJER_2013_vegStr.csv")

# plot centroids
center_SJER <- read.csv("C:/Users/cflagg/Documents/GitHub/pythonWork/pls/SJER_center.csv")

# A) Calculate the real positions of the stems, based on plot centroid (pointID=41), azimuth, and distance

# join foliar and vst data first, since vst data has pointID info -- this should produce unique stuff
SJER_n <- merge(foliar_SJER, vst_SJER, by = "individualID")

#  this plyr call returns all of the columns but takes the maximum individual distance
# # http://stats.stackexchange.com/questions/11193/how-do-i-remove-all-but-one-specific-duplicate-record-in-an-r-data-frame
# # http://stackoverflow.com/questions/27903890/summarize-rows-grouped-by-id-and-preserve-other-non-grouping-variables
# test2 <- ddply(SJER_n,.(individualID),function(x) x[which.max(x$individualdistance),])

# average the azimuths and distances if there are multiple stems
# a way to preserve non-grouping columns while keeping only the first row instance
# http://stackoverflow.com/questions/27903890/summarize-rows-grouped-by-id-and-preserve-other-non-grouping-variables
# slice keeps the first row from each mini-data frame that group_by creates
SJER_n <- SJER_n %>% group_by(individualID) %>% 
  mutate(avgDistance = mean(individualdistance), avgAzimuth = mean(individualazimuth)) %>% slice(1)

# checking the individualIDs that don't overlap
table(foliar_SJER$individualID %in% vst_SJER$individualID)
table(vst_SJER$individualID %in% foliar_SJER$individualID)

# now match up the plot centers with the stemID
SJER_n <- merge(SJER_n, center_SJER, by.x = "plot_id", by.y = "Plot_ID")

# A.1 match up plot center (easting, northing) with a stemID center based on plotID and pointID
# filter rows with Nitrogen data only and point_id == 41 (plot center only)
SJER_n <- SJER_n %>% filter(totalN > 0, pointid == "center") 

# A.2 using the plot center coordinates, calculate the true coordinates of each stem
# calculate x,y coordinates from distance and radians angle -- simply add the plot center coordinates (pointID) to calc new coords
# # these coordinates represent the positions of sampled individuals across ALL PLOTS
# SJER_n$utm_e = with(SJER_n, individualdistance*sin(radians(individualazimuth)) + easting)
# SJER_n$utm_n = with(SJER_n, individualdistance*cos(radians(individualazimuth)) + northing)

# calculate the relative x,y coordinates of the stems (from the top-left corner)
# feed it the averaged distances and azimuths
# pointID 41 and plot center = (20, 20)
SJER_n$rel_x = with(SJER_n, round(avgDistance*sin(radians(avgAzimuth)) + 20))
SJER_n$rel_y = with(SJER_n, round(avgDistance*cos(radians(avgAzimuth)) + 20))

# plot it out
plot(SJER_n$utm_e, SJER_n$utm_n)
plot(SJER_n$rel_x, SJER_n$rel_y)

head(SJER_n)

unique(SJER_n)

# GRAB CANOPY DIMENSIONS TO INFORM SPECTRAL CLIPPING

# store relevant data to pull spectra -- THIS IS A LOOKUP TABLE
flData <- SJER_n %>% select(plot_id, pointid, individualID, rel_x, rel_y, totalN)

flData %>% unique()

# B) Then bring in the H5 files and pull the spectra for each UTM coordinate -- these might have to be 'translated' as well
head(flData)

# for each plotid, open the h5 file and locate the array section specified by the utm coordinates, clip the data
# grab the spatial info for the plot's boundaries -- this doesn't actually matter! the data were sliced in the same way, 
# so the relative positions from the center work just as well, because they match the dimensions of the array

# two variables change in the loop between D17 and D03 conventions: plot_id/plotID and individualID/individual_id

# list to store reflectance data
clip_ref = list()
for (plot in flData$plot_id){
  # browser()
  # open the h5 file for each plotid -- "f" moves the debugger forward one cycle
  ff <-  paste(SJERFiledir, "/", plot,".h5" ,sep="")
  # pull the reflectance data for the specific plotid
  all_ref <- h5read(ff, "Reflectance")
  # pass part of the data frame on to the next loop
  d <- flData[flData$plot_id == plot,] 
  # make sure the correct h5 file is being grabbed
  print(paste(plot, ff))
  # for each plotid, grab the individualID's relative coordinates
  for (stem in d$individualID){
    print(stem)
    # for each individual stem, pull the coordinate information
    stemInfo <- d[which(d$individualID == stem),]
    print(paste(stemInfo$rel_x, stemInfo$rel_y))
    # take the coordinates, slice the array, and store it
    # all_ref[stemInfo$rel_x, stemInfo$rel_y, 1:426] -- lists are indexed with double brackets "list[[]]"
    clip_ref[[stem]] <- all_ref[stemInfo$rel_x, stemInfo$rel_y, 1:426]
  }}

# transform into data frame with wavelength data in each column
SJER_ref <- ldply(clip_ref)
# reset the .id column
colnames(SJER_ref)[1] <- "individualID"

# finally, rejoin with nitrogen and other data, based on individual_id
SJER_out <- merge(SJER_ref, SJER_n, by = "individualID")

# write out the file
write.csv(SJER_out, paste(outdir,"/SJER_n_ref.csv", sep=""))

