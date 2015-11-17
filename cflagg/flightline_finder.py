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
import pandas as pd

basePath = "C:/Users/cflagg/Documents/GitHub/pythonWork/cflagg/"

##############################################################################
# function will pretty print all groups and datasets within the H5 file, when used with method: visit()
def printname(name):
    print name
    
##############################################################################    
# This is practice code; functions that will get the data from map info
# check out the full file
os.chdir('D:/D3/OSBS/2014/OSBS_L1/OSBS_Spectrometer/Reflectance')

# get the list of files in the directory
hfiles = os.listdir(os.getcwd())
##############################################################################
# http://stackoverflow.com/questions/9623398/text-files-in-a-dir-and-store-the-file-names-in-a-list-python
count = 1
fline_list = [] # to store UTM data
fname_list = [] # to store filename
for file in hfiles: 
    print file, count
    f = h5.File(file, 'r') # open the file, read-only
    corner = f['map info'] # grab the dataset's info
    fname_list.append(file) # grab file name
    fline_list.append(corner.value) # this is how you add items to a list
    count = count + 1
    
# find the box dimensions
sto = f['Reflectance'].shape
# split and store -- need to remove parentheses
repr(sto).split(',')[1:3]

# split the fline_list for easting and northing
# only grab easting and northing
flightline_output = pd.DataFrame({'fnames': fname_list, 'fline': fline_list})
    
# write a file
# http://stackoverflow.com/questions/16923281/pandas-writing-dataframe-to-csv-file
flightline_output.to_csv("C:/Users/cflagg/Documents/GitHub/pythonWork/cflagg/OSBS_flightlines.csv", sep = ",", encoding = 'utf-8')

    