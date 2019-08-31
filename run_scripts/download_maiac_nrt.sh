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
doy=`date -d "$y4$m2$d2" +"%j"`

path_data=$2 
path_script=`pwd`

if [ ! -d $path_data ]; then
  mkdir -p $path_data
  chmod a+rx $path_data
fi 


url=https://nrt4.modaps.eosdis.nasa.gov/api/v2/content/archives/allData/6/MCD19A2N/$y4/$doy
appkey='995DB514-938E-11E9-A84B-1138E106C194'

#read the list of tiles to download
tiles=`cat tiles.txt`

#download data 
cd $path_data

  for var in $tiles; do 
    file="MCD19A2N.A"${y4}${doy}.${var}."006.hdf"
    comd="wget -e robots=off -m -np -R .html,.tmp -nH --cut-dirs=9 $url/$file --header \"Authorization: Bearer ${appkey}\" -P $path_data"
    eval $comd
  done
 
chmod a+r $path_data/*


