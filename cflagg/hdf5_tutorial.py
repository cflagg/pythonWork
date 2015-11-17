__author__ = 'cflagg'

import os
import h5py as h5
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
from pprint import pprint

# print names of groups function, call within file.visit(printname)
def printname(name):
    print name

os.chdir('c:/Users/cflagg/Documents/GitHub/pythonWork/canopyN')
# savee working dir
mypath = os.getcwd()

# check files in working dir
os.listdir(mypath)

# open h5 file - this one is created by Leah's script -- it has no meta-data
f = h5.File('SJER36.h5', 'r')

f.name

# this checks the "keys" of the H5 file i.e. what it contains
f.keys()

# store data as dataset object
dset = f['Reflectance']

# check the shape
dset.shape

# check data type
dset.dtype

dset[1]

f.items

f.values

# check out the full file
os.chdir('D:/D3/OSBS/2014/OSBS_L1/OSBS_Spectrometer/Reflectance')
os.listdir(os.getcwd())

# a random H5 file
g = h5.File('NIS1_20140507_143910_atmcor.h5', 'r')

# print names within 'g' -- this calls a function...within a function?
g.visit(printname)

# how do I grab the damn coordinates?
space = g['map info']



# grab the path length dimensions
sto = g['Path Length']

# split it out for the values
repr(sto).split(',')[1:3]

# list different methods
dir(space)
######################################################## get coordinates from map info
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

# split out the string with regex
type(space.value) # this is a numpy,ndarray

pprint(space.value)

pprint(vars(space))

# string splitting example
Str1= 'cody-is-a-good-programmer'
list1 = Str1.split('-')
print list1
