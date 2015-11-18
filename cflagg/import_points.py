# -*- coding: utf-8 -*-
"""
Created on Wed Nov 18 13:52:21 2015

# source: http://invisibleroads.com/tutorials/gdal-shapefile-points-save.html
# http://www.gdal.org/osr_tutorial.html
# http://www.digital-geography.com/csv-to-shp-with-python/#.VkzqB3arSUk

@author: cflagg
"""
import os
import osgeo.ogr, osgeo.osr
import pandas as pd

os.chdir(r'c:/Users/cflagg/Documents/GitHub/pythonWork/canopyN')

basePath='c:/Users/cflagg/Documents/GitHub/pythonWork/canopyN'

osbsPlotCentroid  = basePath+ '/fieldData/OSBSPlotCentroids.csv'

# open the text file
p = open(osbsPlotCentroid)
dfPlotLoc = pd.read_csv(p, header=0)
easting = dfPlotLoc['easting']
northing = dfPlotLoc['northing']

# set spatial reference
spatialReference = osgeo.osr.SpatialReference()
spatialReference.ImportFromProj4('+proj=UTM +zone=17 +ellps=WGS84 +no_defs')

# create shape file
driver = osgeo.ogr.GetDriverByName('ESRI Shapefile')
shapeData = driver.CreateDataSource('OSBS-points.shp')

# create points
point = osgeo.ogr.Geometry(osgeo.ogr.wkbPoint)
point.SetPoint(0,1,easting.tolist(), northing.tolist())

