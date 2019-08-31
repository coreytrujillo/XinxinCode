#!/bin/bash
#
# Download NAM analysis data from NCEP data archive 
# 
# Usage: download_nam_anl.sh yyyymmddhh hour_range hour_interval path_download
# least hour_interval: 6 
#  


runtime=$1
y4=`echo $runtime | cut -c1-4`
y2=`echo $runtime | cut -c3-4`
m2=`echo $runtime | cut -c5-6`
d2=`echo $runtime | cut -c7-8`
h2=`echo $runtime | cut -c9-10`
hour_range=$2
hour_interval=$3
path_download=$4

if [ ! -d $path_download ]; then
    mkdir $path_download
    chmod a+rx $path_download
fi

link='https://www.ftp.ncep.noaa.gov/data/nccf/com/nam/prod'

for dh in `seq -w 0 $hour_interval $hour_range`
do
     dtime=`date -d "$y4$m2$d2 $h2 $dh hour" +"%Y%m%d%H"`
     d_y4=`echo $dtime | cut -c1-4`
     d_m2=`echo $dtime | cut -c5-6`
     d_d2=`echo $dtime | cut -c7-8`
     d_h2=`echo $dtime | cut -c9-10`

     dir=$link/nam.$d_y4$d_m2$d_d2

     fname='nam.t'$d_h2'z.awphys00.tm00.grib2'  # analysis 
     fout=$d_y4$d_m2$d_d2'.'$fname
	 echo "wget -q -nc -O $path_download/$fout $dir/$fname "
     wget -q -nc -O $path_download/$fout $dir/$fname & 

     fname='nam.t'$d_h2'z.awphys03.tm00.grib2'  # analysis 
     fout=$d_y4$d_m2$d_d2'.'$fname
	 echo "wget -q -nc -O $path_download/$fout $dir/$fname"
     wget -q -nc -O $path_download/$fout $dir/$fname

done 

chmod a+r $path_download/*
