Introduction
=======

This repository includes bash scripts that use [Generic Tool Maps (Wessel et al., 2013)](http://gmt.soest.hawaii.edu/projects/gmt) to plot National Observatory of Athens (NOA) earthquake catalogue and historical earthquakes of Papazachos and Papazachou catalogue for the region of Greece. Also you can plot profile of earthquakes...

<!-- [![Build Status](https://api.travis-ci.org/kks32/phd-thesis-template.svg)](https://travis-ci.org/kks32/phd-thesis-template) -->
[![License GPL-3.0](http://img.shields.io/badge/license-GPL-brightgreen.svg)](LICENSE)
[![Version](http://img.shields.io/badge/version-2.0-brightgreen.svg)](https://github.com/demanasta/plot_eq/releases/latest)


----------
**main scripts**

 1. plot_eq.sh : plot earthquakes
 2. plot_eq_proj.sh : plot earthquakes and profiles
 3. plot_hcmt.sh : plot moment tensors from historic earthquakes

**helpful files**

 4. default-param : default parameters for paths, input files and region configuration
 5. get_catalogue.sh : this script download [earthquake NOA catalogue](http://www.gein.noa.gr/services/full_catalogue.php)  and [fault database (Ganas et al., 2020)](http://www.gein.noa.gr/services/GPSData/1_NOAFaults/)

Documentation
============
----------

 - Be sure that gmt is installed on your computer
 - Configure file *default-param*.

If you like to use topography you can download world DEM from [here](https://www.ngdc.noaa.gov/mgg/global/global.html)
 
```
# //////////////////
# Set PATHS parameters
pth2dems=${HOME}/Map_project/dems
inputTopoL=${pth2dems}/ETOPO1_Bed_g_gmt4.grd
inputTopoB=${pth2dems}/ETOPO1_Bed_g_gmt4.grd
pth2logos=$HOME/Map_project/logos
pth2faults=$HOME/Map_project/faults/NOAFaults_v5.01.gmt

#///////////////////
# Set default REGION for GREECE
west=19
east=30.6
south=33
north=42
projscale=6000000
frame=2
```
For main scripts help function run:
```
>$ ./plot_eq.sh -h OR > $ ./plot_eq_proj.sh -h
``` 
**plot_eq.sh**

**MAIN OPTIONS**

 Usage   : plot_eq.sh -r west east south north | -topo | -o [output] | -jpg 

 - r [:= region] region to plot west east south north (default Greece) use: -r west east south north projscale frame
 - mt [:= map title] title map default none use quotes
 - updcat [:= update earthquake catalogue] 
 - topo [:= topography] use DEM topography
 - faults [:= faults] plot NOA fault database
 - histeq [:= historic eq ] plot historical eq via papazachos catalogue
 
**EARTHQUAKE OPTIONS**
 - minmw [:= minimum magnitude]  bug use only int
 - maxmw [:= maximum magnitude]  bug use only int
 - starty [:= start year] 
 - stopy [:= stop year] 
 
**OTHER OPRTIONS**
 - o [:= output] name of output files
 - l [:=labels] plot labels
 - leg [:=legend] insert legends
 - logo [:=logo] plot logo
 - jpg : convert eps file to jpg
 - h [:= help] help menu
 
 Exit Status:    1 -> help message or error
 
 Exit Status: >= 0 -> sucesseful exit

example:
```
$ ./plot_eq.sh -topo -faults -jpg -leg
```


----------
----------
**plot_eq_proj.sh**
In these script added an optio to plot rofile of earthquakes

  -eqproj [:=projection] plot projectio along profile
  ```    use -eqproj lon lat Az Lmin Lmax Wmin Wmax depth```
  
lon: start longitude of profile

lat: start latitude of profile

Az: Azimuth of profile

Lmin, Lmax: Profile Length start-stop

Wmin, Wmax: Profile width on the two sides of profile
depth: depth of profile

# Updates

- 21-1-2015: online version is available
- 03-8-2023: update to GMT v6.3.0, bug fixed

References
=========
Athanassios Ganas. (2023). NOAFAULTS KMZ layer Version 5.0 (V5.0) [Data set]. Zenodo. https://doi.org/10.5281/zenodo.8075517

Wessel, P., Luis, J. F., Uieda, L., Scharroo, R., Wobbe, F., Smith, W. H. F., & Tian, D. (2019). The Generic Mapping Tools version 6. Geochemistry, Geophysics, Geosystems, 20, 5556–5564. https://doi.org/10.1029/2019GC008515

Contact
=========
Dimitris Anastasiou, danastasiou@mail.ntua.gr

Xanthos Papanikolaou, xanthos@mail.ntua.gr


