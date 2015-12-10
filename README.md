# pythonWork
This repository centers around (1) extracting, processing, and geo-locating AOP data with field-collected Foliar Nitrogen data and (2) wrangling and visualizing the extracted data for the D03 (2014) and D17 (2013) prototypes

Below is an abstraction of the workflow for my 2015 AGU poster. Airborne data extraction scripting file workflow (where "[]" indicates a folder/file and "{}" indicates an input/output):

**(Step 1 - Extract AOP data)**
{inputs: all HDF5 files for a single site; plot boundaries shapefile; flightlineID per plotID} >> [canopyN/ExtractPlotSpectra_siteID.py] >> {outputs: NDNI pixels for each unique plotID, as separate HDF5 files}

**(Step 2 - Regress NDNI ~ Foliar N)**
{inputs: NDNI calculated per pixel per plotID; foliar nitrogen data per plot} >> [canopyN/processFieldData_siteID] >> {outputs: plot averaged NDNI; plot averaged foliar nitrogen}

**(Step 3 - Extract Single Pixel per tree stem coordinate)** 
{inputs: HDF5 file per plotID; field coordinates of tree stems} >> [pls/pull_spectra_from_h5_siteID.R] >> {outputs: a 3D array of reflectance per unique stemID per plotID}

**(Step 4 - Regress Single Pixel against foliar N per stemID)** 
{inputs: stemID reflectance; stemID foliar_N} >> [cflagg/pls_foliarN.Rmd] >> {outputs: PLS regression results and figures}
