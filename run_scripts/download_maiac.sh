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

path_data=$2 
path_script=`pwd`

if [ ! -d $path_data ]; then
  mkdir -p $path_data
  chmod a+rx $path_data
fi 

url="https://e4ftl01.cr.usgs.gov/MOTA/MCD19A2.006/"$y4"."$m2"."$d2

#read the list of tiles to download
tiles=`cat tiles.txt`

#get the urls of files to download, filter by tiles (h**v**)
cd $path_data
rm -f *.txt

    #get contents in the folder
    wget -p -q -O tmp.txt $url 
  for var in $tiles; do 
    cat tmp.txt | grep $var | sed 's/ /--/g' >filename.txt
    cat filename.txt | grep hdf'"'>filename2.txt
    file=`cat filename2.txt`
    file2=${file##*='"'}
    file=${file2%%'"'>*}
    echo $url"/"$file>>file_to_download.txt
  done
 
$path_script/download_maiac_cred.sh

wait
rm -f *.txt 
chmod a+r $path_data/*



