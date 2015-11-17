# -*- coding: utf-8 -*-
"""
Created on Tue Nov 17 08:39:28 2015

This script will loop through HDF5 files, grab the map info, and compare it to plotID gps coordinates 
in order to determine which flightlines provide the best extent and spectra for clipping and extraction. 

@author: cflagg
"""

##############################################################################

import os
import h5py as h5
import glob
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
from pprint import pprint

##############################################################################
# function will pretty print all groups and datasets within the H5 file, when used with method: visit()
def printname(name):
    print name
    
##############################################################################    
# This is practice code; functions that will get the data from map info
# check out the full file
os.chdir('D:/D3/OSBS/2014/OSBS_L1/OSBS_Spectrometer/Reflectance')

hfiles = os.listdir(os.getcwd())

# a random H5 file
g = h5.File('NIS1_20140507_143910_atmcor.h5', 'r')

# print names within 'g' -- this calls a function...within a function?
g.visit(printname)

# how do I grab the damn coordinates?
space = g['map info']

# list different methods
dir(space)

# get coordinates from map info
# this returns the data stored by 'space' 
coords = space.value
# convert numpy ndarray to list, then repr() returns an object as a string
store = repr(coords.tolist())
# now split the string
store = store.split(',')
# easting coordinate
store[3]
# northing coordinate
store[4]
##############################################################################
# http://stackoverflow.com/questions/9623398/text-files-in-a-dir-and-store-the-file-names-in-a-list-python
count = 1
fline_list = [] # to store UTM data
fname_list = [] # to store filename
for file in hfiles: 
    print file, count
    f = h5.File(file, 'r')
    corner = f['map info']
    fname_list.append(file)
    fline_list.append(corner.value) # this is how you add items to a list
    count = count + 1

# split the fline_list for easting and northing
# only grab easting and northing

pd.DataFrame({'fnames': fname_list, 'fline': fline_list})
    
    

    