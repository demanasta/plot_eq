#!/bin/bash
# //////////////////////////////////////////////////////////////////////////////
# HELP FUNCTION
function help {
	echo "/******************************************************************************/"
	echo " Program Name : plot_eq.sh"
	echo " Version : v-0.1"
	echo " Purpose : Plot earthquakes of NOA catalogue for Greece"
	echo " Default param file: default-param"
	echo " Usage   : plot_eq.sh -r west east south north | -topo | -o [output] | -jpg "
	echo " Switches: "
        echo "           -r [:= region] region to plot west east south north (default Greece)"
        echo "                   use: -r west east south north projscale frame"
        echo "           -mt [:= map title] title map default none use quotes"
        echo "           -updcat [:= update catalogue] title map default none use quotes"
        echo "           -topo [:= update catalogue] title map default none use quotes"
        echo "           -faults [:= faults] plot NOA fault database"
        echo "           -histeq [:= historic eq ] plot historical eq via papazachos catalogue"
	echo ""
        echo "/*** EARTHQUAKE OPTIONS **********************************************************/"
        echo "           -minmw [:= minimum magnitude]  bug use only int"
        echo "           -maxmw [:= maximum magnitude]  bug use only int"
	echo "           -starty [:= start year] "
	echo "           -stopy [:= stop year] "
	echo ""
        echo "/*** OTHER OPRTIONS ************************************************************/"
	echo "           -o [:= output] name of output files"
	echo "           -l [:=labels] plot labels"
        echo "           -leg [:=legend] insert legends"
        echo "           -logo [:=logo] plot logo"
	echo "           -jpg : convert eps file to jpg"
	echo "           -h [:= help] help menu"
	echo " Exit Status:    1 -> help message or error"
	echo " Exit Status: >= 0 -> sucesseful exit"
	echo ""
	echo "run: ./plot_eq.sh -topo -faults -jpg -leg"
	echo "/******************************************************************************/"
	exit 1
}

# //////////////////////////////////////////////////////////////////////////////
# GMT parameters
gmt gmtset MAP_FRAME_TYPE fancy
gmt gmtset PS_PAGE_ORIENTATION portrait
gmt gmtset FONT_ANNOT_PRIMARY 10 FONT_LABEL 10 MAP_FRAME_WIDTH 0.12c FONT_TITLE 18p

# //////////////////////////////////////////////////////////////////////////////
# Pre-defined parameters for bash script
# REGION="greece"
TOPOGRAPHY=0
FAULTS=0
LABELS=0
LOGO=0
OUTJPG=0
LEGEND=0
UPDCAT=0
HISTEQ=0

##LOAD DEFAULT PARAMETERS
echo "... load deafault parameters file ..."
source default-param
# # //////////////////////////////////////////////////////////////////////////////
# # Set PATHS parameters
# pth2dems=${HOME}/Map_project/dems
# # pth2nets=${HOME}/Map_project/4802_SEISMO/networks
# inputTopoL=${pth2dems}/ETOPO1_Bed_g_gmt4.grd
# inputTopoB=${pth2dems}/ETOPO1_Bed_g_gmt4.grd
# pth2logos=$HOME/Map_project/logos
# pth2faults=$HOME/Map_project/faults/NOAFaults_v1.0.gmt


# //////////////////////////////////////////////////////////////////////////////
# Set default files
outfile=plot_eq.eps
out_jpg=plot_eq.jpg
landcpt=land_man.cpt
bathcpt=bath_man.cpt
# maptitle=""

# # //////////////////////////////////////////////////////////////////////////////
# # Set default REGION for GREECE
# west=19
# east=30.6
# south=33
# north=42
# projscale=6000000
# frame=2

# //////////////////////////////////////////////////////////////////////////////
# Set default magnitude interval
minmw=4
maxmw=10

# //////////////////////////////////////////////////////////////////////////////
# Set default time period
starty=2000
stopy=$(date --date="-1 day" +%Y)

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
			west=$2
			east=$3
			south=$4
			north=$5
			projscale=$6
			frame=$7
# 			REGION=$2
			shift
			shift
			shift
			shift
			shift
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
			TOPOGRAPHY=1
			shift
			;;
		-faults)
			FAULTS=1
			shift
			;;	
		-histeq)
			HISTEQ=1
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
		-logo)
			LOGO=1
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

#////////////START
	echo "/******************************************************************************/"
	echo " Program Name : plot_eq.sh"
	echo " Version : v-0.1"
	echo " Purpose : Plot earthquakes of NOA catalogue for Greece"
	echo " Default param file: default-param"
	echo "/******************************************************************************/"


# //////////////////////////////////////////////////////////////////////////////
# check if files exist

###check dems
if [ "$TOPOGRAPHY" -eq 1 ]
then
	if [ ! -f $inputTopoB ]
	then
		echo "grd file for topography toes not exist, var turn to coastline"
		TOPOGRAPHY=0
	fi
fi

###check NOA catalogue
if [ ! -f full_NOA.catalogue ]
then
	echo "NOA CATALOGUE does not exist, will be doanloaded, use -updcat switch next time"
	UPDCAT=1
fi

###check HISTORIC earthquakes
if [ ! -f papazachos_db ]
then
	echo "Historic eq database does not exist, scr will not plot these data"
	HISTEQ=0
fi

###check NOA FAULT catalogue
if [ "$FAULTS" -eq 1 ]
then
	if [ ! -f $pth2faults ]
	then
		echo "NOA Faults database does not exist"
		echo "please download it and then use this switch"
		FAULTS=0
	fi
fi

###check LOGO file
if [ ! -f "$pth2logos" ]
then
	echo "Logo file does not exist"
	LOGO=0
fi


# //////////////////////////////////////////////////////////////////////////////
# SET REGION PROPERTIES
	#these are default for GREECE REGION
gmt	gmtset PS_MEDIA 26cx22c
	scale="-Lf20/33.5/36:24/100+l+jr"
	range="-R$west/$east/$south/$north"
	proj="-Jm24/37/1:$projscale"
	logo_pos="BL/6c/-1.5c/DSO[at]ntua"
	logo_pos2="-C16c/15.6c"
	legendc="-Jx1i -R0/8/0/8 -Dx18.5c/12.6c/3.6c/3.5c/BL"	
	maptitle="Seismicity from $starty to $stopy"
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
gmt	psbasemap $range $proj $scale -B$frame:."$maptitle": -P -K > $outfile
gmt	pscoast -R -J -O -K -W0.25 -G195 -Df -Na -U$logo_pos >> $outfile
# 	pscoast -Jm -R -Df -W0.25p,black -G195  -U$logo_pos -K -O -V >> $outfile
# 	psbasemap -R -J -O -K --FONT_ANNOT_PRIMARY=10p $scale --FONT_LABEL=10p >> $outfile
fi
if [ "$TOPOGRAPHY" -eq 1 ]
then
	# ####################### TOPOGRAPHY ###########################
	# bathymetry
gmt	makecpt -Cgebco.cpt -T-7000/0/150 -Z > $bathcpt
gmt	grdimage $inputTopoB $range $proj -C$bathcpt -K > $outfile
gmt	pscoast $proj -P $range -Df -Gc -K -O >> $outfile
	# land
gmt	makecpt -Cgray.cpt -T-3000/1800/50 -Z > $landcpt
gmt	grdimage $inputTopoL $range $proj -C$landcpt  -K -O >> $outfile
gmt	pscoast -R -J -O -K -Q >> $outfile
	#------- coastline -------------------------------------------
gmt	psbasemap -R -J -O -K -B$frame:."$maptitle": --FONT_ANNOT_PRIMARY=10p $scale --FONT_LABEL=10p >> $outfile
gmt	pscoast -J -R -Df -W0.25p,black -K  -O -U$logo_pos >> $outfile
fi

# psbasemap -R$west/$east/$south/$north $proj $tick -P -Y12 -K > $out
# 
# makecpt -Crelief -T-8000/8000/500 -Z > topo.cpt
# 
# grdimage $topo -R -J -O -K -Ctopo.cpt   >> $out
# 
# pscoast -R -J -O -K -W0.25 -G195 -Df -Na -Ia -Lf-130.8/46/10/200+lkm >> $outfile

#////////////////////////////////////////////////////////////////
#  PLOT NOA CATALOGUE FAULTS Ganas et.al, 2013
if [ "$FAULTS" -eq 1 ]
then
	echo "plot NOA FAULTS CATALOGUE Ganas et.al, 2013 ..."
gmt	psxy $pth2faults -R -J -O -K  -W.5,204/102/0  >> $outfile
fi

#////////////////////////////////////////////////////////////////
#  PLOT Historic catalogue, Papazachos
if [ "$HISTEQ" -eq 1 ]
then
# 	awk '{print $8,$7,$9}' tmp-eq34 | psxy -R -J -O -K  -W.1 -Sc.11 -Cseis2.cpt>> $outfile
	echo "plot HISTORIC Earthquakes, Papazachos ana Papazacho catalogue"
	awk -F, '{print $5,$4,$7}' papazachos_db |gmt psxy -R -J -O -K  -W.1 -Ss.11 -Gblack >> $outfile
	
fi

#////////////////////////////////////////////////////////////////
#create temporary earthquake files
#select with years
awk 'NR != 2 {if ($1>='$starty' && $1<='$stopy') print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10}' full_NOA.catalogue > tmp-eq1
#select with magnitude
# awk 'NR != 2 {if ($10>='$minmw' && $10<='$maxmw') print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10}' tmp-eq1 > tmp-eq2
cat tmp-eq1>tmp-eq2
#split to magnitude categories
awk 'NR != 0 {if ($10>=0 && $10<2) print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10}' tmp-eq2 > tmp-eq02
awk 'NR != 0 {if ($10>=2 && $10<3) print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10}' tmp-eq2 > tmp-eq23
awk 'NR != 0 {if ($10>=3 && $10<4) print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10}' tmp-eq2 > tmp-eq34
awk 'NR != 0 {if ($10>=4 && $10<5) print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10}' tmp-eq2 > tmp-eq45
awk 'NR != 0 {if ($10>=5 && $10<6) print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10}' tmp-eq2 > tmp-eq56
awk 'NR != 0 {if ($10>=6 && $10<8) print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10}' tmp-eq2 > tmp-eq68

# start create legend file .legend
echo "G 0.2c" > .legend
# echo "H 10 Times-Roman FROM: $starty" >> .legend
# echo "H 10 Times-Roman   TO: $stopy" >> .legend
echo "G 0.2c" > .legend

echo "H 11 Times-Roman Magnitude" >> .legend
echo "D 0.3c 1p" >> .legend
echo "N 1" >> .legend

#////////////////////////////////////////////////////////////////
#plot 
gmt	makecpt -Cseis -T0/150/10 -Z > seis2.cpt
if [ "$minmw" -lt 2 ] && [ "$maxmw" -gt 2 ]
then
	awk '{print $8,$7,$9}' tmp-eq02 | gmt psxy -R -J -O -K  -W.1 -Sc.05 -Cseis2.cpt>> $outfile
	echo "G 0.25c" >> .legend
	echo "S 0.4c c 0.05c 160 0.22p 0.9c Mw < 2" >> .legend
fi
if [ "$minmw" -lt 3 ] && [ "$maxmw" -gt 2 ]
then
	awk '{print $8,$7,$9}' tmp-eq23 | gmt psxy -R -J -O -K  -W.1 -Sc.09 -Cseis2.cpt>> $outfile
	echo "G 0.25c" >> .legend
	echo "S 0.4c c 0.09c 160 0.22p 0.9c 2 =< Mw < 3" >> .legend
fi
if [ "$minmw" -lt 4 ] && [ "$maxmw" -gt 3 ]
then
	awk '{print $8,$7,$9}' tmp-eq34 | gmt psxy -R -J -O -K  -W.1 -Sc.11 -Cseis2.cpt>> $outfile
	echo "G 0.25c" >> .legend
	echo "S 0.4c c 0.11c 160 0.22p 0.9c 3 =< Mw < 4" >> .legend
fi
if [ "$minmw" -lt 5 ] && [ "$maxmw" -gt 4 ]
then
	awk '{print $8,$7,$9}' tmp-eq45 | gmt psxy -R -J -O -K  -W.1 -Sc.15 -Cseis2.cpt>> $outfile
	echo "G 0.25c" >> .legend
	echo "S 0.4c c 0.15c 160 0.22p 0.9c 4 =< Mw < 5" >> .legend
fi
if [ "$minmw" -lt 6 ] && [ "$maxmw" -gt 5 ]
then
	awk '{print $8,$7,$9}' tmp-eq56 | gmt psxy -R -J -O -K  -W.1 -Sc.25 -Cseis2.cpt>> $outfile
	echo "G 0.25c" >> .legend
	echo "S 0.4c c 0.25c 160 0.22p 0.9c 5 =< Mw < 6" >> .legend
fi
if [ "$minmw" -lt 10 ] && [ "$maxmw" -gt 6 ]
then
	awk '{print $8,$7,$9}' tmp-eq68 | gmt psxy -R -J -O -K  -W.1 -Sa.8 -Cseis2.cpt >> $outfile
	echo "G 0.25c" >> .legend
	echo "S 0.4c a 0.8c 160 0.22p 0.9c 6 =< Mw" >> .legend
fi
# awk '{print($4,$3,$5)}' $seis_data | psxy -R -J -O -K  -W.1 -Sc.1 -Cseis.cpt -H15 >> $out 

gmt psscale -D19.7c/3.1c/-4c/0.6c -B50:Depth:/:km: -Cseis2.cpt -O -K >> $outfile

# psxy center.dat -R -J -O -K -W1 -Sc.3 -G255/0/0 >> $out
# psxy center.dat -R -J -O -K -W5/255/0/0 >> $out


# ////////////////////////////////////////////////////PLOT PROJECTION!!! ////////////////////////////////
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
echo "G 0.2c" >> .legend
echo "D 0.3c 1p" >> .legend
echo "G 0.3c" >> .legend
# echo "B seis2.cpt 0.2i 0.2i" >> .legend
echo "T Earthquake data automated recovered via NOA catalogue" >> .legend
echo "G 1.6c" >> .legend
echo "D 0.3c 1p" >> .legend
echo "T NOA FAULTS CATALOGUE after Ganas et.al, 2013" >> .legend

# ///////////////// PLOT LEGEND //////////////////////////////////
if [ "$LEGEND" -eq 1 ]
then
gmt	pslegend .legend ${legendc} -C0.1c/0.1c -L1.3 -O -K >> $outfile
fi

#/////////////////PLOT LOGO DSO
if [ "$LOGO" -eq 1 ]
then
gmt	psimage $pth2logos -O $logo_pos2 -W1.1c -F0.4  -K >>$outfile
fi

#//////// close eps file
echo "9999 9999" | gmt psxy -J -R  -O >> $outfile

#################--- Convert to jpg format ----##########################################
if [ "$OUTJPG" -eq 1 ]
then
	gs -sDEVICE=jpeg -dJPEGQ=100 -dNOPAUSE -dBATCH -dSAFER -r300 -sOutputFile=$out_jpg $outfile
fi

# ///////////////// REMOVE TMP FILES //////////////////////////////////
rm tmp-*
rm .legend
rm *cpt

# NOA FAULTS reference
# Ganas Athanassios, Oikonomou Athanassia I., and Tsimi Christina, 2013. NOAFAULTS: a digital database for active faults in Greece. Bulletin of
#  the Geological Society of Greece, vol. XLVII and Proceedings of the 13th International Congress, Chania, Sept. 2013.

# historic eq papazachos reference
echo $?
