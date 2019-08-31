#!/bin/sh  
if [ $# -ne 2 ]; then
   echo 'Usage :' $0 yyyymmdd path_to_put_data
   exit 1
fi

runtime=$1
y4=`echo $runtime | cut -c1-4`
y2=`echo $runtime | cut -c3-4`
m2=`echo $runtime | cut -c5-6`
d2=`echo $runtime | cut -c7-8`

path_store=$2/$y4$m2$d2
if [ ! -d $path_store ]; then
    mkdir $path_store
    chmod a+rx $path_store
fi

url='ftp://ftp.star.nesdis.noaa.gov/pub/smcd/hzhang/VIIRS_EPS_NRT/AOD/CONUS'
wget -r --no-parent --cut-dirs=9  -cN -nH -P $path_store  $url/$runtime && echo "Success!"|| echo "Download failed. Please retrieve the data again:"$url/$runtime 

chmod a+r $path_store/* 
