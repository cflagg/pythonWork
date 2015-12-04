# -*- coding: utf-8 -*-
"""
Created on Mon Nov 23 17:54:03 2015

@author: cflagg

source: https://wiki.python.org/moin/UsingPickle
"""

import pickle
import os


basePath='c:/Users/cflagg/Documents/GitHub/pythonWork/canopyN'
fileDirectory = (r'D:/D17/SJER/2013/SJER_L1/SJER_Spectrometer/2013061320/Reflectance/')

#else:
#    #path to MAC git repo
#    basePath='/Users/lwasser/Documents/GitHub/pythonWork/canopyN'
#    fileDirectory = (r'/Volumes/My Passport/D17_Data_2014_Distro/02_SJER/SJER_Spectrometer_Data/2013061320/Reflectance/')

os.chdir(basePath)
os.getcwd()

#os.chdir('c:/Users/lwasser/Documents/GitHub/pythonWork/canopyN')
#Identify the Site you wish to query data for
site='SJER'

###################### Define Paths ##################################
#Define Field Data Path
plotH5FilePath= basePath + '/data/h5/'
#fieldDataPath='F:/D17_Data_2014_Distro/06_Field_Data/Sampling_Data/D17_Foliar_Chemistry/'

fieldDataPath=basePath + '/fieldData/'

# Pickle location for NDNI data
ndniPicklePath = basePath + "/data/processed/ndni_pickles/"

##################### Pickle Things ##################################

# save the NDNI data with pickle -- defaults to working directory
pickle.dump(NDNI, open("NDNI_JERC.p","wb"))

# load the pickle -- again, defaults to working dir
NDNI = pickle.load(open(ndniPicklePath+ "NDNI_OSBS.p", "rb"))

sto = NDNI['OSBS011']

# numpyArray.shape gives dimensions 
sto.shape