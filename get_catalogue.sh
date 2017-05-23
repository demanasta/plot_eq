#! /bin/bash

##
## Utility to download NOA's :
##  1. full catalogue (full_catalogue.php)
##  2. fault info (GPSData/1_NOAFaults/NOAFaults_v1.0.gmt)
##
## Returns 0 on success
##

echo "downloading NOA's full catalogue; this may take a while ..."
if ! wget -q -O full_NOA.catalogue \
             http://www.gein.noa.gr/services/full_catalogue.php ; then
    echo 1>&2 "Error. Failed to download NOA's catalogue."
    exit 1
fi

echo "downloading NOA's faults info; this may take a while ..."
if ! wget -q -O NOAFaults_v1.gmt \
            http://www.gein.noa.gr/services/GPSData/1_NOAFaults/NOAFaults_v1.0.gmt ; then
    echo 1>&2 "Error. Failed to download NOA's faults info."
    exit 2
fi

exit 0
