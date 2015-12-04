# best flightline finder
# THIS CODE WORKS but the d1,d2 strategy does not work well

fline = read.csv(file.choose(),header=T)
plots = read.csv(file.choose(),header=T)


# join two files together by plotID
dat = merge(fline, plots, by="plotID")

# calculate distances (d1, d2) between bottom-right and upper-left hand corners
# sqrt((x1 - x2)^2 + (y1 - y2)^2)

dat$d1 = with(dat, sqrt((x1 - easting)^2 + (y1 - northing)^2))
dat$d2 = with(dat, sqrt((x2 - easting)^2 + (y2 - northing)^2))

# find the plotId with the lowest difference between d1 and d2, this point is most equidistant between the boundaries
dat$ddiff = with(dat, d1 - d2)

# find plotID and h5 file with smallest diff value
library(plyr)
library(plyr)

# solution: http://stackoverflow.com/questions/24070714/r-how-to-group-data-by-column-find-min-value-in-each-group-then-extract-3rd-c
# plyr can treat the column names as an indexable data.frame based on the newly created column e.g. colName[which(newColName)]
bestLine = ddply(dat, .(plotID), summarise,
      min_diff = min(abs(ddiff)),  # grab the minimum absolute difference value    
      min_fline = flightline[which.min(min_diff)], # based on the minimum difference value, append the flightLine number that matches the min
      min_fname = fileName[which.min(min_diff)]) # from min diff, append fileName that matches the min_diff value

# test plotting
test = dplyr::filter(dat, plotID == "JERC_001")

plot(test$x1, test$y1)
plot(test$x2, test$y2, col = "red")
points(x = test$easting, y = test$northing)

write.csv(bestLine, file = "JERC_bestTiles.csv")
