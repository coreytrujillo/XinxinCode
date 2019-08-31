#!/bin/bash

year_i=$1
month_i=$2
day_i=$3
hour_i=$4
timestep_tracer=${5}
timestep_nofire=${6} #forecast lenght for WRF no fire run
timestep=${7} # forecast lenght for WRF analysis run
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

# Wait until this hour and minute to download NNR files
#hour_download_nnr=13 # Local hour at which NNR can be downloaded
#min_download_nnr=35 
#hour_i_nnr=00
 hour_f_nnr=16

#timestep_nnr=$[$timestep_tracer-72] 
#timestep_nnr=$[$timestep_tracer-64] 
timestep_nnr=0

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

    date_aux="${year_i}-${month_i}-${day_i} ${hour_i}:00:00"
    year_f_nofire=$(date --date "$date_aux  ${timestep_nofire} hours" '+%Y')
    month_f_nofire=$(date --date "$date_aux  ${timestep_nofire} hours" '+%m')
    day_f_nofire=$(date --date "$date_aux  ${timestep_nofire} hours" '+%d')
    hour_f_nofire=$(date --date "$date_aux  ${timestep_nofire} hours" '+%H')
    date_end_nofire=$(date --date "$date_aux  ${timestep_nofire} hours" '+%F_%T')
    echo "Date end NO FIRE D01= ${year_f_nofire}-${month_f_nofire}-${day_f_nofire}_${hour_f_nofire}:00:00"

    date_aux="${year_i}-${month_i}-${day_i} ${hour_i}:00:00"
    year_i_nnr=$(date --date "$date_aux  ${timestep_nnr} hours" '+%Y')
    month_i_nnr=$(date --date "$date_aux  ${timestep_nnr} hours" '+%m')
    day_i_nnr=$(date --date "$date_aux  ${timestep_nnr} hours" '+%d')
    hour_i_nnr=$(date --date "$date_aux  ${timestep_nnr} hours" '+%H')
    echo "Date start NNR= ${year_i_nnr}-${month_i_nnr}-${day_i_nnr}_${hour_i_nnr}:00:00"

    # wait until NNR data becomes available
#    current_epoch=$(date +%s)
#    date_aux2="${year_f}-${month_f}-${day_f} ${hour_download_nnr}:${min_download_nnr}:00"
#    target_epoch=$(date --date "$date_aux2" '+%s')
#    sleep_seconds=$(( $target_epoch - $current_epoch ))
#    if [ $sleep_seconds -gt 0 ]
#    then
#     echo "WAITING FOR NNR DATA, Sleep ${sleep_seconds}"
#     sleep $sleep_seconds
#     echo "Wake up at $(date +%F_%T)!"
#    else
#     echo "NOT WAITING FOR NNR DATA"
#    fi

    # Download NNR data
#    cd ${path_script}
#    echo "./download_nnr_data.sh ${year_f} ${month_f} ${day_f} '${path_nnr_store}'"
#    eval "./download_nnr_data.sh ${year_f} ${month_f} ${day_f} '${path_nnr_store}'"
#    wait

#    path_nnr_data="${path_nnr_store}/${year_f}${month_f}"


    # Put NNR into Matlab format
   cd ${path_nnr_script}
cat <<ENDF >write_dasilva_matlab_file_submit.m
   cd ${path_nnr_script};
   write_dasilva_matlab_file_fn([$year_i_nnr $month_i_nnr $day_i_nnr $hour_i_nnr 0 0],[$year_f $month_f $day_f $hour_f 0 0],'${path_nnr_data}/');
   exit;
ENDF
   cmd="matlab.q write_dasilva_matlab_file_submit.m"
   echo $cmd
   eval $cmd
    sleep 5 
   status=`qstat -u ctrujil1 | grep write_dasi`
    while [ -n "$status" ] ;do
        echo 'Waiting: NNR to mat format...'
        sleep 60
        status=`qstat -u ctrujil1 | grep write_dasi`
    done
    echo 'Complete: NNR to mat format!'

    # Run inversion
    cd ${path_matlab}
cat <<ENDF >compare_dasilva_aod_tracer_submit.m
    cd ${path_matlab};
    compare_dasilva_aod_tracer_gthomp_68tr_fn([$year_i_nnr $month_i_nnr $day_i_nnr $hour_i_nnr 0 0],[$year_f $month_f $day_f $hour_f 0 0],${Ntracer1},[$year_i $month_i $day_i $hour_i 0 0],'${WRF_TRACER_OUT_week}/','${WRF_NOFIRE_OUT_week}/','${path_nnr_data}/','${path_matlab}');
    exit;
ENDF
    cat compare_dasilva_aod_tracer_submit.m
    cmd="matlab.q compare_dasilva_aod_tracer_submit.m"
    echo $cmd
    eval $cmd
    sleep 5
    echo "Waiting inversion to complete..."
    status=`qstat -u ctrujil1 | grep compare_da`
    while [ -n "$status" ] ;do
        sleep 60
        status=`qstat -u ctrujil1 | grep compare_da`
    done
    echo 'Complete inversion!'


    # Create constrained emissions
    # compute final date of the forecast
    date_aux="${year_i}-${month_i}-${day_i} ${hour_i}:00:00"
    year_f2=$(date --date "$date_aux  ${timestep} hours" '+%Y')
    month_f2=$(date --date "$date_aux  ${timestep} hours" '+%m')
    day_f2=$(date --date "$date_aux  ${timestep} hours" '+%d')
    hour_f2=$(date --date "$date_aux  ${timestep} hours" '+%H')
    date_end2=$(date --date "$date_aux  ${timestep} hours" '+%F_%T')
    echo "Date end D01= ${year_f2}-${month_f2}-${day_f2}_${hour_f2}:00:00"

    # compute final date of the 16 Tracer
    date_aux="${year_i}-${month_i}-${day_i} ${hour_i}:00:00"
    year_f3=$(date --date "$date_aux  ${timestep_16tracer} hours" '+%Y')
    month_f3=$(date --date "$date_aux  ${timestep_16tracer} hours" '+%m')
    day_f3=$(date --date "$date_aux  ${timestep_16tracer} hours" '+%d')
    hour_f3=$(date --date "$date_aux  ${timestep_16tracer} hours" '+%H')
    date_end3=$(date --date "$date_aux  ${timestep_16tracer} hours" '+%F_%T')
    echo "Date 16 Tracer= ${year_f3}-${month_f3}-${day_f3}_${hour_f3}:00:00"

    # Run matlab script to scale emissions
    cd ${path_matlab}

cat <<ENDF > scale_fire_emissions_inversion_submit.m 
    cd ${path_matlab};
    scale_fire_emissions_inversion_68tr_SkipLastDay_fn([$year_i $month_i $day_i $hour_i 0 0],[$year_f2 $month_f2 $day_f2 $hour_f2 0 0],[$year_i $month_i $day_i $hour_i 0 0],[$year_f $month_f $day_f $hour_f 0 0],[$year_i_nnr $month_i_nnr $day_i_nnr $hour_i_nnr 0 0],[$year_f $month_f $day_f $hour_f 0 0],${Ntracer1},'${FIRE_OUT_week}/','${FIRE_ANA_OUT_week}/','${WRF_TRACER_DIR}/wrfinput_d01','cluster');
    exit
ENDF
    cat scale_fire_emissions_inversion_submit.m 
    cmd="matlab.q scale_fire_emissions_inversion_submit.m"
    echo $cmd
    eval $cmd
    status=`qstat -u ctrujil1 | grep scale_fire`
    echo "Waiting: emissions scaling..."
    while [ -n "$status" ] ;do
        sleep 60
        status=`qstat -u ctrujil1 | grep scale_fire`
    done
    echo 'Complete scale emissions!'


    # Create tracers for final run
    cd ${path_matlab}
cat <<ENDF >create_tracer_emissions_submit.m 
    cd ${path_matlab};
    create_tracer_emissions_16tr_fn([$year_i $month_i $day_i $hour_i 0 0],[$year_f2 $month_f2 $day_f2 $hour_f2 0 0],[$year_i $month_i $day_i $hour_i 0 0],[$year_f3 $month_f3 $day_f3 $hour_f3 0 0],${Ntracer2},'${FIRE_ANA_OUT_week}/','${FIRE_ANA_TRACER_OUT_week}/','${input_path_anthro}/','${WRF_TRACER_DIR}/wrfinput_d01');
    exit;
ENDF
    cmd="matlab.q create_tracer_emissions_submit.m"
    echo $cmd
    eval $cmd
    status=`qstat -u ctrujil1 | grep create_tra`
    echo "Waiting: creating tracers..."
    while [ -n "$status" ] ;do
        sleep 60
        status=`qstat -u ctrujil1 | grep create_tra`
    done
    echo 'Complete creating tracers!'
   # change permission 
   cd ..
   /bin/chmod -R a+r ./

exit


