# -*- coding: utf-8 -*-
"""
Created on Wed Nov 18 12:21:26 2015

Create buffer

# a non-ogr source: https://gist.github.com/rustyrothwurt/3d207b3af6d1fe04d1e3

@author: cflagg
"""

import ogr
import pandas as pd
import os
import pprint
import numpy as np

basePath='c:/Users/cflagg/Documents/GitHub/pythonWork/canopyN'

osbsPlotCentroid  = basePath+ '/fieldData/OSBSPlotCentroids.csv'

# open the text file
p = open(osbsPlotCentroid)
dfPlotLoc = pd.read_csv(p, header=0)
dfPlotLoc['easting']
dfPlotLoc['northing']

#open a file with the correct coordinate system (CRS)
driver = ogr.GetDriverByName('ESRI Shapefile')
dataset = driver.Open(r'c:/Users/cflagg/Documents/GitHub/pythonWork/canopyN/data/sjerPlots/SJERPlotCentroids_Buff_Square.shp')

# extract CRS from An existing Layer
layer = dataset.GetLayer()
spatialRef = layer.GetSpatialRef()

#Create new shapefile
driver = ogr.GetDriverByName('ESRI Shapefile')
# if this file exists in the directory it will throw an Error 1, remove the file first and re-run
# source: http://lists.osgeo.org/pipermail/gdal-dev/2006-March/008130.html
new_shape = driver.CreateDataSource(r'C:/Users/cflagg/Documents/GitHub/pythonWork/canopyN/data/sjerPlots/new_shapefile.shp') 
layer = new_shape.CreateLayer('Layer 1', spatialRef, ogr.wkbPolygon)
fieldDefn = ogr.FieldDefn('File_Name', ogr.OFTString)
fieldDefn.SetWidth(14) 
layer.CreateField(fieldDefn)