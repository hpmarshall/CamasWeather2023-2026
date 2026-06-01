# CamasWeather2023-2026
miniMet data from Camas Prairie for WY 2023-2026   

This is the final dataset from the Liquid Propane pre-experiment evaluation for IDWR and Idaho Power.  See also https://github.com/hpmarshall/CamasWeather, the original repo that has many of the scripts that produced figures for annual reports.   

SNODAR/ : data files from the laser-based snow depth sensors   
SNODAR/RAW/ : raw datafiles downloaded from sensors   
SNODAR/CSV/ : cleaned data in CSV format for WY2023-2026    
miniMET/ : raw data files from the mini meteorological stations (temp, RH, pressure, wind)   
miniMET/RAW/ : raw datafiles downloaded from miniMET Onset U30 loggers   
LIDAR/ : files associated with airborne lidar snow depth survey, February 8, 2025   
iSNOBAL/ : files associated with snow energy and mass balance modeling, WY2020-2025   
IN_SITU/ : snowpits, SWE cores, interval boards, field notes   
FIGURES/ : figures created for reports, meetings (see also CamasWeather repo)   

loadCamasWeather.m : reads in raw data, performs QA/QC, and stores in structure array database, and outputs to CSVs.   
readSNOdar.m : reads an individual SNODAR data file   
readSNOdarStation.m : reads all SNODAR data files for an individual station   
plotCamasWeather.m : makes summary plots of WY2023-2026   
download_snotel_camas_creek : downloads entire historical record (WY1993-2026) of Camas Creek Divide SNOTEL using NRCS API    
CamasSNOTEL.m : Makes plot showing historical context of WY2023-2026   
readOnset.m : reads an individual miniMET data file   
readOnsetStation.m: reads all data from a single station   

Camas2023-26miniMet.mat : matlab data file with structure arrays containing the database of all observations (miniMet,SNODAR,SNOTEL)   
      NOTE: for non-MATLAB users, CSV files for miniMet and SNODAR data are in the CSV subdirectories.   

