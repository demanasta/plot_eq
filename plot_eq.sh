#!/bin/bash
# //////////////////////////////////////////////////////////////////////////////
# HELP FUNCTION
function help {
	echo "/******************************************************************************/"
	echo " Program Name : plot_eq.sh"
	echo " Version : v-0.1"
	echo " Purpose : Plot earthquakes of NOA catalogue for Greece"
	echo " Usage   : plot_eq.sh -r west east south north |  | -o [output] | -jpg "
	echo " Switches: "
        echo "           -r [:= region] region to plot west east south north (default Greece)"
        echo "           -mt [:= map title] title map default none use quotes"
        echo "           -updcat [:= update catalogue] title map default none use quotes"
        echo "           -topo [:= update catalogue] title map default none use quotes"

        echo "/*** EARTHQUAKE OPTIONS **********************************************************/"
        echo "           -minmw [:= minimum magnitude] "
        echo "           -maxmw [:= maximum magnitude] "
        echo "           -starty [:= start year] "
	echo "           -stopy [:= stop year] "


        echo "/*** OTHER OPRTIONS ************************************************************/"
	echo "           -o [:= output] name of output files"
	echo "           -l [:=labels] plot labels"
        echo "           -leg [:=legend] insert legends"
	echo "           -jpg : convert eps file to jpg"
	echo "           -h [:= help] help menu"
	echo " Exit Status:   -2 -> help message or error"
	echo " Exit Status: >= 0 -> sucesseful exit"
	echo ""
	echo "run:"
	echo "/******************************************************************************/"
	exit -2
}

# //////////////////////////////////////////////////////////////////////////////
# GMT parameters
gmtset MAP_FRAME_TYPE fancy
gmtset PS_PAGE_ORIENTATION portrait
gmtset FONT_ANNOT_PRIMARY 10 FONT_LABEL 10 MAP_FRAME_WIDTH 0.12c FONT_TITLE 18p

# //////////////////////////////////////////////////////////////////////////////
# Pre-defined parameters for bash script
# REGION="greece"
TOPOGRAPHY=0
LABELS=0
OUTJPG=0
LEGEND=0
UPDCAT=0

# //////////////////////////////////////////////////////////////////////////////
# Set PATHS parameters
pth2dems=${HOME}/Map_project/dems
# pth2nets=${HOME}/Map_project/4802_SEISMO/networks
inputTopoL=${pth2dems}/ETOPO1_Bed_g_gmt4.grd
inputTopoB=${pth2dems}/ETOPO1_Bed_g_gmt4.grd
pth2logos=$HOME/Map_project/logos


# //////////////////////////////////////////////////////////////////////////////
# Set default files
outfile=test.eps
out_jpg=test.jpg
landcpt=land_man.cpt
bathcpt=bath_man.cpt
maptitle=""

# //////////////////////////////////////////////////////////////////////////////
# Set default REGION for GREECE
west=19
east=29
south=34
north=42

# //////////////////////////////////////////////////////////////////////////////
# Set default magnitude interval
minmw=4
maxmw=10

# //////////////////////////////////////////////////////////////////////////////
# Set default time period
starty=1980
stopy=2015

# //////////////////////////////////////////////////////////////////////////////
# GET COMMAND LINE ARGUMENTS
if [ "$#" == "0" ]
then
	help
fi

while [ $# -gt 0 ]
do
	case "$1" in
		-r)
			REGION=$2
			shift
			shift
			;;
		-mt)
			maptitle=$2
			shift
			shift
			;;
		-updcat)
			UPDCAT=1
			shift
			;;
		-minmw)
			minmw=$2
			shift
			shift
			;;
		-maxmw)
			maxmw=$2
			shift
			shift
			;;
		-starty)
			starty=$2
			shift
			shift
			;;
		-stopy)
			stopy=$2
			shift
			shift
			;;
		-topo)
#                       switch topo not used in server!
			TOPOGRAPHY=1
			shift
			;;
		-o)
			outfile=${2}.eps
			out_jpg=${2}.jpg
			shift
			shift
			;;
		-l)
			LABELS=1
			shift
			;;
		-leg)
			LEGEND=1
			shift
			;;
		-jpg)
			OUTJPG=1
			shift
			;;
		-h)
			help
			;;
	esac
done



# out=cascadia_seis.ps 				# This will be the name of your map generated by this file
# seis_data=NCEDC_Search_Results.dat			# ANSS earthquake catalog
# topo=../../dems/greeceSRTM.grd			# ETOPO1 topography grid


tick='-B2/2WSen'

proj='-Jm24/37/1:6000000'
# //////////////////////////////////////////////////////////////////////////////
# SET REGION PROPERTIES
	gmtset PS_MEDIA 21cx29c
	frame=2
	scale=-Lf20/34.5/36:24/100+l+jr
	range=-R$west/$east/$south/$north
	proj=-Jm24/37/1:6000000
	logo_pos=BL/19c/0.2c/"NOA Catalogue"
	logo_pos2="-C14.8c/0.1c"
	legendc="-Jx1i -R0/8/0/8 -Dx0.3c/0.6c/3.6c/4.3c/BL"	
	
# //////////////////////////////////////////////////////////////////////////////
# UPDATE NOA CATALOGUE
if [ "$UPDCAT" -eq 1 ]
then
	wget http://www.gein.noa.gr/services/full_catalogue.php -O full_NOA.catalogue
fi
# ####################### TOPOGRAPHY ###########################
if [ "$TOPOGRAPHY" -eq 0 ]
then
	################## Plot coastlines only ######################	
	pscoast $range $proj -B$frame:."$maptitle": -Df -W0.5/0/0/0 -G195 -Na  -U$logo_pos -K -Y12 > $outfile
	psbasemap -R -J -O -K --FONT_ANNOT_PRIMARY=10p $scale --FONT_LABEL=10p >> $outfile
fi
if [ "$TOPOGRAPHY" -eq 1 ]
then
	# ####################### TOPOGRAPHY ###########################
	# bathymetry
	makecpt -Cgebco.cpt -T-7000/0/150 -Z > $bathcpt
	grdimage $inputTopoB $range $proj -C$bathcpt -K -Y12 > $outfile
	pscoast $proj -P $range -Df -Gc -K -O >> $outfile
	# land
	makecpt -Cgray.cpt -T-3000/1800/50 -Z > $landcpt
	grdimage $inputTopoL $range $proj -C$landcpt  -K -O >> $outfile
	pscoast -R -J -O -K -Q >> $outfile
	#------- coastline -------------------------------------------
	psbasemap -R -J -O -K --FONT_ANNOT_PRIMARY=10p $scale --FONT_LABEL=10p >> $outfile
	pscoast -Jm -R -B$frame:."$maptitle": -Df -Na  -W -K  -O -U$logo_pos >> $outfile
fi


# psbasemap -R$west/$east/$south/$north $proj $tick -P -Y12 -K > $out
# 
# makecpt -Crelief -T-8000/8000/500 -Z > topo.cpt
# 
# grdimage $topo -R -J -O -K -Ctopo.cpt   >> $out
# 
# pscoast -R -J -O -K -W2 -Df -Na -Ia -Lf-130.8/46/10/200+lkm >> $out

makecpt -Crainbow -T0/50/10 -Z > seis.cpt

awk '{print($4,$3,$5)}' $seis_data | psxy -R -J -O -K  -W.1 -Sc.1 -Cseis.cpt -H15 >> $out 

psscale -D0/3.2/6/1 -B10:Depth:/:km: -Cseis.cpt -O -K >> $out

psxy center.dat -R -J -O -K -W1 -Sc.3 -G255/0/0 >> $out
psxy center.dat -R -J -O -K -W5/255/0/0 >> $out


# ////////////////////////////////////////////////////PLOT PROJRCTION!!! /\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
# awk '{print($4,$3,$5)}' $seis_data | project -C21/36 -A45 -W-.2/.2 -L0/4 -H15 > projection.dat
# 
# 
# east=25
# west=21 
# dmin=0 
# dmax=50
# 
# proj=-JX15/-5
# tick=-B1:Longitude:/10:Depth:WSen
# 
# 
# awk '{print($6,$3)}' projection.dat | psxy -R$west/$east/$dmin/$dmax $proj $tick -W1 -Sc.2 -G200 -O  -Y-8 -P >> $out

#/////////////////PLOT LOGO DSO
psimage $pth2logos/DSOlogo2.eps -O $logo_pos2 -W1.1c -F0.4 >>$outfile

#################--- Convert to jpg format ----##########################################
if [ "$OUTJPG" -eq 1 ]
then
	gs -sDEVICE=jpeg -dJPEGQ=100 -dNOPAUSE -dBATCH -dSAFER -r300 -sOutputFile=$out_jpg $outfile
fi

