# -*- coding: utf-8 -*-
"""
Created on Mon Nov 23 17:54:03 2015

@author: cflagg

source: https://wiki.python.org/moin/UsingPickle
"""

import pickle

# save the NDNI data with pickle -- defaults to working directory
pickle.dump(NDNI, open("NDNI_SJER.p","wb"))

# load the pickle -- again, defaults to working dir
NDNI = pickle.load(open("NDNI_SJER.p", "rb"))