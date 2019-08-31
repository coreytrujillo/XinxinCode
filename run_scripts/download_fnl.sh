#!/bin/bash
# by Xinxin Ye, Apr 2019
# Usage: download_fnl.sh yyyymmddhh hour_range hour_interval path_download

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
fi

link='ftp://ftp.ncep.noaa.gov/pub/data/nccf/com/gfs/prod'
user='anonymous'
pass='saide'
file_prefix='gdas.t'
file_middle='z.pgrb2.0p25.f'
file_sufix=''

for dh in `seq 0 $hour_interval $hour_range`

do
     dtime=`date -d "$y4$m2$d2 $h2 $dh hour" +"%Y%m%d%H"`
       d_y4=`echo $dtime | cut -c1-4`
       d_m2=`echo $dtime | cut -c5-6`
       d_d2=`echo $dtime | cut -c7-8`
       d_h2=`echo $dtime | cut -c9-10`
       dir=$link/gdas.$d_y4$d_m2$d_d2

     val=`expr $dh % 6 `

     if [ $val -eq 0 ]; then
       fname=$file_prefix$d_h2$file_middle'000'
       fout='gdas1.fnl0p25.'$dtime'.f00.grib2'
     else
       dtime2=`date -d "$d_y4$d_m2$d_d2 $d_h2 -3 hour" +"%Y%m%d%H"`
       d2_y4=`echo $dtime2 | cut -c1-4`
       d2_m2=`echo $dtime2 | cut -c5-6`
       d2_d2=`echo $dtime2 | cut -c7-8`
       d2_h2=`echo $dtime2 | cut -c9-10`
       fname=$file_prefix$d2_h2$file_middle'003' 
       fout='gdas1.fnl0p25.'$dtime2'.f03.grib2'
     fi
     wget --user=$user --password=$pass -nc -O $path_download/$fout $dir/$fname


done 

