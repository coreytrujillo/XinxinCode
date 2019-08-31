#!/bin/bash

if [ $# -ne 2 ]; then
   echo 'Usage :' $0 yyyymmdd path_to_put_data
   exit 1
fi

runtime=$1
path_store=$2
y4=`echo $runtime | cut -c1-4`
y2=`echo $runtime | cut -c3-4`
m2=`echo $runtime | cut -c5-6`
d2=`echo $runtime | cut -c7-8`

if [ ! -d $path_store ]; then
    mkdir $path_store
    chmod a+rx $path_store 
fi

cd ${path_store}

url='https://portal.nccs.nasa.gov/datashare/iesa/aerosol/missions/KORUS-AQ/061/Level2'

wget -r --timeout=10 --tries=5 -nH --cut-dirs=10 --no-parent --timestamping -A "*.${y4}${m2}${d2}_*" $url/MOD04/Y${y4}/M${m2}/
wget -r --timeout=10 --tries=5 -nH --cut-dirs=10 --no-parent --timestamping -A "*.${y4}${m2}${d2}_*" $url/MYD04/Y${y4}/M${m2}/

chmod a+r $path_store/*
