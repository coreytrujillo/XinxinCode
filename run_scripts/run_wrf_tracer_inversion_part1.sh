#!/bin/bash 

year_i=$1
month_i=$2
day_i=$3
hour_i=$4
timestep_tracer=${5}
timestep_nofire=${6} 
timestep=${7} 
timestep_16tracer=${8}
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


# Sequence:
# Run WRF-tracer and WRF_no_fire
# Run inversion
# Run analysis

    # Create namelist.input for WRF-tracer and WRF_no_fire

    date_aux="${year_i}-${month_i}-${day_i} ${hour_i}:00:00"
    echo "Date start TRACER D01= ${year_i}-${month_i}-${day_i}_${hour_i}:00:00"
    year_f=$(date --date "$date_aux  ${timestep_tracer} hours" '+%Y')
    month_f=$(date --date "$date_aux  ${timestep_tracer} hours" '+%m')
    day_f=$(date --date "$date_aux  ${timestep_tracer} hours" '+%d')
    hour_f=$(date --date "$date_aux  ${timestep_tracer} hours" '+%H')
    date_end=$(date --date "$date_aux  ${timestep_tracer} hours" '+%F_%T')
    echo "Date end TRACER D01= ${year_f}-${month_f}-${day_f}_${hour_f}:00:00"

    cd $WRF_TRACER_DIR
    sed -e "s/_SAAAA1_/${year_i}/g
      " -e "s/_SMM1_/${month_i}/g
      " -e "s/_SDD1_/${day_i}/g
      " -e "s/_SHH1_/${hour_i}/g
      " -e "s/_EAAAA1_/${year_f}/g
      " -e "s/_EMM1_/${month_f}/g
      " -e "s/_EDD1_/${day_f}/g
      " -e "s/_EHH1_/${hour_f}/g
      " -e "s/_steps_/${timestep_tracer}/g
      " -e "s/_RESTART_/.false./g
      " -e "s/_RST_INTERVAL_/1440/g
      " ${path_script}/namelist.input.tracer.sed > tmpfile
    mv -f tmpfile namelist.input

    date_aux="${year_i}-${month_i}-${day_i} ${hour_i}:00:00"
    year_f_nofire=$(date --date "$date_aux  ${timestep_nofire} hours" '+%Y')
    month_f_nofire=$(date --date "$date_aux  ${timestep_nofire} hours" '+%m')
    day_f_nofire=$(date --date "$date_aux  ${timestep_nofire} hours" '+%d')
    hour_f_nofire=$(date --date "$date_aux  ${timestep_nofire} hours" '+%H')
    date_end_nofire=$(date --date "$date_aux  ${timestep_nofire} hours" '+%F_%T')
    echo "Date end NO FIRE D01= ${year_f_nofire}-${month_f_nofire}-${day_f_nofire}_${hour_f_nofire}:00:00"

    cd $WRF_NOFIRE_DIR
    sed -e "s/_SAAAA1_/${year_i}/g
      " -e "s/_SMM1_/${month_i}/g
      " -e "s/_SDD1_/${day_i}/g
      " -e "s/_SHH1_/${hour_i}/g
      " -e "s/_EAAAA1_/${year_f_nofire}/g
      " -e "s/_EMM1_/${month_f_nofire}/g
      " -e "s/_EDD1_/${day_f_nofire}/g
      " -e "s/_EHH1_/${hour_f_nofire}/g
      " -e "s/_steps_/${timestep_nofire}/g
      " -e "s/_RESTART_/.false./g
      " -e "s/_RST_INTERVAL_/1440/g
      " ${path_script}/namelist.input.nofire.sed > tmpfile
    mv -f tmpfile namelist.input

    # Submit
    cd $WRF_NOFIRE_DIR
    eval "/bin/rm rsl.*"
    qsub run_wrf_test.csh

    cd $WRF_TRACER_DIR
    eval "/bin/rm rsl.*"
    qsub run_wrf_test.csh


    echo "Waiting wrf_tracer to complete..."
    echo "Waiting wrf_nofire to complete..."

    status=`qstat -u ctrujil1 | grep wrfnof`
    while [ -n "$status" ] ;do
        sleep 5
        status=`qstat -u ctrujil1 | grep wrfnof`
    done
    echo 'Complete WRF nofire run!'

    status=`qstat -u ctrujil1 | grep wrftra`
    while [ -n "$status" ] ;do
        sleep 5
        status=`qstat -u ctrujil1 | grep wrftra`
    done
    echo 'Complete WRF tracer run!'


    # copy
    eval "/bin/cp ${WRF_TRACER_DIR}/namelist.input ${WRF_TRACER_OUT_week}/"
    eval "/bin/cp ${WRF_TRACER_DIR}/rsl.error.0000 ${WRF_TRACER_OUT_week}/"
    eval "/bin/mv ${WRF_TRACER_DIR}/wrfout_d0* ${WRF_TRACER_OUT_week}/"
    eval "/bin/cp ${WRF_NOFIRE_DIR}/namelist.input ${WRF_NOFIRE_OUT_week}/"
    eval "/bin/cp ${WRF_NOFIRE_DIR}/rsl.error.0000 ${WRF_NOFIRE_OUT_week}/"
    eval "/bin/mv ${WRF_NOFIRE_DIR}/wrfout_d0* ${WRF_NOFIRE_OUT_week}/"
 
    # remove files 
    eval "/bin/rm ${joiner_path}/nml*00:00"
    eval "/bin/rm ${joiner_path}/join.o*"

    # Join WRF files
    cd $joiner_path
    eval "./submit_runjoiner_fn.sh ${year_i} ${month_i} ${day_i} ${hour_i} ${timestep_tracer} 1 '${WRF_TRACER_OUT_week}' '${WRF_TRACER_OUT_week}' 'tracer'"
    eval "./submit_runjoiner_fn.sh ${year_i} ${month_i} ${day_i} ${hour_i} ${timestep_nofire} 1 '${WRF_NOFIRE_OUT_week}' '${WRF_NOFIRE_OUT_week}' 'nofire'"

    # Check status 
    status=`qstat -u ctrujil1 | grep join`
    while [ -n "$status" ] ;do
        sleep 5
        status=`qstat -u ctrujil1 | grep join`
    done
    echo 'Joining tile files finish!'

    # Check that joiner was suscessfull and erase tile files
    cd $joiner_path
    eval "./erase_wrfout_tile_files.sh ${year_i} ${month_i} ${day_i} ${hour_i} ${timestep_tracer} 1 '${WRF_TRACER_OUT_week}' '${WRF_TRACER_OUT_week}' 'tracer' "
    eval "./erase_wrfout_tile_files.sh ${year_i} ${month_i} ${day_i} ${hour_i} ${timestep_nofire} 1 '${WRF_NOFIRE_OUT_week}' '${WRF_NOFIRE_OUT_week}' 'nofire' "

    # change permission 
    /bin/chmod a+rx ${WRF_NOFIRE_OUT_week}
    /bin/chmod a+r ${WRF_NOFIRE_OUT_week}/* 
    /bin/chmod a+rx ${WRF_TRACER_OUT_week}
    /bin/chmod a+r ${WRF_TRACER_OUT_week}/* 

exit

