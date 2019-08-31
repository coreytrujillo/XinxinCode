#!/bin/bash

year_i=$1
month_i=$2
day_i=$3
hour_i=$4
timestep_tracer=${5}
timestep_nofire=${6} #forecast lenght for WRF no fire run
timestep=${7} # forecast lenght for WRF analysis run
timestep_8tracer=${8}
WRF_TRACER_DIR=${9}
WRF_NOFIRE_DIR=${10}
WRF_ANALYSIS_DIR=${11}
WRF_TRACER_OUT_week=${12}
WRF_NOFIRE_OUT_week=${13}
WRF_ANALYSIS_OUT_week=${14}
FIRE_OUT_week=${15}
FIRE_ANA_OUT_week=${16}
FIRE_ANA_TRACER_OUT_week=${17}
input_path_anthro=${18}
lat_lon_file=${19}
path_script=${20}
path_matlab=${21}
path_nnr_store=${22}
path_nnr_script=${23}
joiner_path=${24}
Ntracer1=${25}
Ntracer2=${26}


timestep_nofire_rst=$[$timestep-$timestep_nofire]


    # Create namelist.input for WRF-tracer and WRF_no_fire

    date_aux="${year_i}-${month_i}-${day_i} ${hour_i}:00:00"
    echo "Date start TRACER D01= ${year_i}-${month_i}-${day_i}_${hour_i}:00:00"


    year_f=$(date --date "$date_aux  ${timestep_tracer} hours" '+%Y')
    month_f=$(date --date "$date_aux  ${timestep_tracer} hours" '+%m')
    day_f=$(date --date "$date_aux  ${timestep_tracer} hours" '+%d')
    hour_f=$(date --date "$date_aux  ${timestep_tracer} hours" '+%H')
    date_end=$(date --date "$date_aux  ${timestep_tracer} hours" '+%F_%T')
    echo "Date end TRACER D01= ${year_f}-${month_f}-${day_f}_${hour_f}:00:00"

    year_f_nofire=$(date --date "$date_aux  ${timestep_nofire} hours" '+%Y')
    month_f_nofire=$(date --date "$date_aux  ${timestep_nofire} hours" '+%m')
    day_f_nofire=$(date --date "$date_aux  ${timestep_nofire} hours" '+%d')
    hour_f_nofire=$(date --date "$date_aux  ${timestep_nofire} hours" '+%H')
    date_end_nofire=$(date --date "$date_aux  ${timestep_nofire} hours" '+%F_%T')
    echo "Date end NO FIRE D01= ${year_f_nofire}-${month_f_nofire}-${day_f_nofire}_${hour_f_nofire}:00:00"

    # Create constrained emissions
    # compute final date of the forecast
    year_f2=$(date --date "$date_aux  ${timestep} hours" '+%Y')
    month_f2=$(date --date "$date_aux  ${timestep} hours" '+%m')
    day_f2=$(date --date "$date_aux  ${timestep} hours" '+%d')
    hour_f2=$(date --date "$date_aux  ${timestep} hours" '+%H')
    date_end2=$(date --date "$date_aux  ${timestep} hours" '+%F_%T')
    echo "Date end D01= ${year_f2}-${month_f2}-${day_f2}_${hour_f2}:00:00"

    # compute final date of the 8 Tracer
    date_aux="${year_i}-${month_i}-${day_i} ${hour_i}:00:00"
    year_f3=$(date --date "$date_aux  ${timestep_8tracer} hours" '+%Y')
    month_f3=$(date --date "$date_aux  ${timestep_8tracer} hours" '+%m')
    day_f3=$(date --date "$date_aux  ${timestep_8tracer} hours" '+%d')
    hour_f3=$(date --date "$date_aux  ${timestep_8tracer} hours" '+%H')
    date_end3=$(date --date "$date_aux  ${timestep_8tracer} hours" '+%F_%T')
    echo "Date 8 Tracer= ${year_f3}-${month_f3}-${day_f3}_${hour_f3}:00:00"

    # Link fire emissions
    cd $WRF_ANALYSIS_DIR
    rm wrffirechemi_d*
    ln -sf ${FIRE_ANA_TRACER_OUT_week}/wrffirechemi_d01_${year_i}* .

    # Run analysis and restart no-fire run

    cd $WRF_ANALYSIS_DIR
    sed -e "s/_SAAAA1_/${year_i}/g
      " -e "s/_SMM1_/${month_i}/g
      " -e "s/_SDD1_/${day_i}/g
      " -e "s/_SHH1_/${hour_i}/g
      " -e "s/_EAAAA1_/${year_f2}/g
      " -e "s/_EMM1_/${month_f2}/g
      " -e "s/_EDD1_/${day_f2}/g
      " -e "s/_EHH1_/${hour_f2}/g
      " -e "s/_steps_/${timestep}/g
      " -e "s/_RESTART_/.false./g
      " -e "s/_RST_INTERVAL_/1440/g
      " ${path_script}/namelist.input.tracer.sed > tmpfile
    mv -f tmpfile namelist.input

    # Submit
    cd $WRF_ANALYSIS_DIR
    eval "/bin/rm rsl.*"
    qstat run_wrf.csh 

    # wait until both simulations are done
    echo "Waiting wrf_analysis to complete..."

    sleep 5

    status=`qstat -u ctrujil1 | grep wrfana`
    while [ -n "$status" ] ;do
        sleep 5
        status=`qstat -u ctrujil1 | grep wrfana`
    done
    echo 'Complete WRF tracer run!'


    # copy
    eval "/bin/cp ${WRF_ANALYSIS_DIR}/namelist.input ${WRF_ANALYSIS_OUT_week}/"
    eval "/bin/cp ${WRF_ANALYSIS_DIR}/rsl.error.0000 ${WRF_ANALYSIS_OUT_week}/"

    # remove files 
    cd $joiner_path
    eval "/bin/rm ${joiner_path}/nml*00:00"
    eval "/bin/rm ${joiner_path}/join.o*"

    # Join WRF files
    eval "./submit_runjoiner_reserve.sh ${year_i} ${month_i} ${day_i} ${hour_i} ${timestep} 1 '${WRF_ANALYSIS_DIR}' '${WRF_ANALYSIS_OUT_week}' 'analy'"

    # Check status 
    status=`qstat -u ctrujil1 | grep join`
    while [ -n "$status" ] ;do
        sleep 5
        status=`qstat -u ctrujil1 | grep join`
    done
    echo 'Joining tile files finish!'

    # Check that joiner was suscessfull and erase tile files
    eval "./erase_wrfout_tile_files_reserve.sh ${year_i} ${month_i} ${day_i} ${hour_i} ${timestep} 1 '${WRF_ANALYSIS_DIR}' '${WRF_ANALYSIS_OUT_week}' 'analy'"
    rm ${WRF_ANALYSIS_DIR}/wrfrst_d01* 

    # change permission 
    /bin/chmod a+rx ${WRF_ANALYSIS_OUT_week}
    /bin/chmod a+r ${WRF_ANALYSIS_OUT_week}/* 

    # post processing 
    cd ${path_script}
    source /usr/share/modules/init/sh
    export NETCDF=/nasa/netcdf/4.4.1.1_serial/
    export LD_LIBRARY_PATH=/nasa/hdf5/1.8.18_serial/lib:$NETCDF:$LD_LIBRARY_PATH
    module load other/comp/gcc-5.3-sp3
    module load other/nco-4.6.8-gcc-5.3-sp3
    module load other/python/GEOSpyD/Ana2018.12_py2.7
    module load other/ncl-6.3.0
    
    rm ${path_script}/postp.o* 
    eval "./post_proc.sh ${year_f} ${month_f} ${day_f} 00 84  3 '${WRF_ANALYSIS_OUT_week}' '${WRF_ANALYSIS_OUT_week}'"
    #eval "./post_proc_reserve.sh ${year_f} ${month_f} ${day_f} 00 84  3 '${WRF_ANALYSIS_OUT_week}' '${WRF_ANALYSIS_OUT_week}'"
    
    # change permission 
    /bin/chmod a+r ${WRF_ANALYSIS_OUT_week}/* 

    exit

