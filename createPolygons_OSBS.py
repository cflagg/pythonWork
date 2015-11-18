# -*- coding: utf-8 -*-
"""
Created on Sun Nov 30 16:30:54 2014
this code uses the final outputs from createFileINventory and plots boundaries of each flight line
to ensure things are correct.
@author: law
"""

#https://code.google.com/p/invest-natcap/wiki/PolygonCreationInOGR

#Some notes on installing GDAL on a mac
#http://www.davidlemayian.com/post/60791205171/how-to-install-python-gdal-on-os-x

#the code below is the easiest way to install GDAL. sometimes you get errors where
#it can't put things in the correct directory -- going through homebrew fixes things.
# $ brew install gdal 
# $ sudo pip install GDAL

import os
from osgeo import ogr
from pprint import pprint

#open a file with the correct coordinate system (CRS)
driver = ogr.GetDriverByName('ESRI Shapefile')
dataset = driver.Open(r'c:/Users/cflagg/Documents/GitHub/pythonWork/canopyN/data/osbsPlots/OSBS_plotBound.shp')

# extract CRS from Layer
layer = dataset.GetLayer()
spatialRef = layer.GetSpatialRef()

#Create new shapefile
driver = ogr.GetDriverByName('ESRI Shapefile')
# if this file exists in the directory it will throw an Error 1, remove the file first and re-run
# source: http://lists.osgeo.org/pipermail/gdal-dev/2006-March/008130.html
new_shape = driver.CreateDataSource(r'C:/Users/cflagg/Documents/GitHub/pythonWork/canopyN/data/osbsPlots/osbs_shapefile.shp') 
layer = new_shape.CreateLayer('Layer 1', spatialRef, ogr.wkbPolygon)
fieldDefn = ogr.FieldDefn('File_Name', ogr.OFTString)
fieldDefn.SetWidth(14) 
layer.CreateField(fieldDefn)
#fieldDefn = ogr.FieldDefn('nameTwo', ogr.OFTString)
#fieldDefn.SetWidth(14) 
#layer.CreateField(fieldDefn)


#loop through each extent file and populate geometry--
for f in xrange(len(finalLookup)):
    #this code will take a set of points and create polygons.
    polygon = ogr.Geometry(ogr.wkbPolygon)
    
    # first create the points that makeup the polygon
    edge = ogr.Geometry(ogr.wkbLinearRing)
    
    #edge.AddPoint(left, top)
    #edge.AddPoint(right, top)
    #edge.AddPoint(right, bottom)
    #edge.AddPoint(left, bottom)
    
    #fileExtents=[onlyH5files[f],yTop,yBot,xLeft,xRight,mapInfo] 
    
    edge.AddPoint(finalLookup[f][3],finalLookup[f][1])
    edge.AddPoint(finalLookup[f][4],finalLookup[f][1])
    edge.AddPoint(finalLookup[f][4],finalLookup[f][2])
    edge.AddPoint(finalLookup[f][3],finalLookup[f][2])
    
    edge.CloseRings()
    
    # create the polygon from a set of points
    rectangle = ogr.Geometry(ogr.wkbPolygon)
    rectangle.AddGeometry(edge)
    
    # add feature to the shapefile opened above.
    feature_def = layer.GetLayerDefn()
    new_feature = ogr.Feature(feature_def)
    new_feature.SetGeometry(rectangle)
    new_feature.SetFID(f)
    
    #At this juncture, it should be noted that you could also add attributes
    #to the feature using new_feature's SetField() method, which takes in two
    #parameters- the name of the field, and that field's value.
    #For this, if we wanted to add a field called 'Name', the call would be
    #new_feature.SetField('Name', 'MyNewRectangle')
    
    #add the file name to the extend boundary
    layer.CreateFeature(new_feature)
    new_feature.SetField('File_Name', (finalLookup[f][0]))
    layer.SetFeature(new_feature)
    #new_feature.SetField('nameTwo','2')
    #layer.SetFeature(new_feature)
    #new_feature.SetField('Name', finalLookup[2][0])
    
    #new_shape = None
    
    rectangle.Destroy()
    new_feature.Destroy()

new_shape.Destroy()



#create map in python
#http://gis.stackexchange.com/questions/61862/simple-thematic-mapping-of-shapefile-using-python
