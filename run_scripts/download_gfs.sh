#!/bin/bash
#
# Download NAM forecast data from NCEP data archive 
# 
# Usage: download_nam.sh yyyymmddhh hour_range hour_interval path_download
# 


runtime=$1
hour_range=$2
hour_interval=$3
path_download=$4

y4=`echo $runtime | cut -c1-4`
y2=`echo $runtime | cut -c3-4`
m2=`echo $runtime | cut -c5-6`
d2=`echo $runtime | cut -c7-8`
h2=`echo $runtime | cut -c9-10`


if [ ! -d $path_download ]; then
    mkdir $path_download
    chmod a+rx $path_download
fi

link='https://www.ftp.ncep.noaa.gov/data/nccf/com/gfs/prod/'
dir=$link/nam.$y4$m2$d2

for dh in `seq -w 0 $hour_interval $hour_range`
do
     fname='nam.t'$h2'z.awphys'$dh'.tm00.grib2'
     fout=$y4$m2$d2'.'$fname
     wget -nc -O $path_download/$fout $dir/$fname


done 

chmod a+r $path_download/*
