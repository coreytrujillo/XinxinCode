#!/bin/bash

year_i=$1
month_i=$2
day_i=$3
hour_i=$4
timestep_tracer=${5}
timestep_nofire=${6} # WRF no fire run
timestep=${7} # WRF analysis run
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
path_maiac_data=${20}
path_maiac_script=${21}
path_matlab=${22}
joiner_path=${23}
Ntracer1=${24}
Ntracer2=${25}

# Wait until this hour and minute to start inversion 
#hh_st=03
#mm_st=15 

#timestep_nnr=$[$timestep_tracer-72] 
#timestep_nnr=$[$timestep_tracer-64] 
off_maiac=24  # offset hours from the beginning 

# Sequence:
# Run WRF-tracer and WRF_no_fire
# Run inversion
# Run analysis

    # Create namelist.input for WRF-tracer and WRF_no_fire

    date_aux="${year_i}-${month_i}-${day_i} ${hour_i}:00:00"
    echo "Date start TRACER D01= ${year_i}-${month_i}-${day_i}_${hour_i}:00:00"


    year_f=$(date -d "$date_aux  ${timestep_tracer} hours" '+%Y')
    month_f=$(date -d "$date_aux  ${timestep_tracer} hours" '+%m')
    day_f=$(date -d "$date_aux  ${timestep_tracer} hours" '+%d')
    hour_f=$(date -d "$date_aux  ${timestep_tracer} hours" '+%H')
    echo "Date end TRACER D01= ${year_f}-${month_f}-${day_f}_${hour_f}:00:00"

    year_f_nofire=$(date -d "$date_aux  ${timestep_nofire} hours" '+%Y')
    month_f_nofire=$(date -d "$date_aux  ${timestep_nofire} hours" '+%m')
    day_f_nofire=$(date -d "$date_aux  ${timestep_nofire} hours" '+%d')
    hour_f_nofire=$(date -d "$date_aux  ${timestep_nofire} hours" '+%H')
    echo "Date end NO FIRE D01= ${year_f_nofire}-${month_f_nofire}-${day_f_nofire}_${hour_f_nofire}:00:00"

    year_i_maiac=$(date -d "$date_aux  ${off_maiac} hours" '+%Y')
    month_i_maiac=$(date -d "$date_aux  ${off_maiac} hours" '+%m')
    day_i_maiac=$(date -d "$date_aux  ${off_maiac} hours" '+%d')
    hour_i_maiac=$(date -d "$date_aux  ${off_maiac} hours" '+%H')
    echo "Date start MAIAC= ${year_i_maiac}-${month_i_maiac}-${day_i_maiac}_${hour_i_maiac}:00:00"



    # wait until MAIAC data becomes available
 #   current_epoch=$(date +%s)
 #   date_aux2="${year_f}-${month_f}-${day_f} ${hour_download_nnr}:${min_download_nnr}:00"
 #   target_epoch=$(date --date "$date_aux2" '+%s')
 #   sleep_seconds=$(( $target_epoch - $current_epoch ))
 #   if [ $sleep_seconds -gt 0 ]
 #   then
 #    echo "WAITING FOR NNR DATA, Sleep ${sleep_seconds}"
 #    sleep $sleep_seconds
 #    echo "Wake up at $(date +%F_%T)!"
 #   else
 #    echo "NOT WAITING FOR NNR DATA"
 #   fi


# re-grid MAIAC data 
# ------------------
    
   cd ${path_maiac_script}
cat >write_maiac_matlab_file.sh << ENDF 
#!/usr/bin/sh
#PBS -N maiac
#PBS -l select=1:ncpus=1:model=bro
#PBS -l walltime=0:20:00
cd ${path_maiac_script}
source /usr/share/modules/init/sh
module load matlab/2017b

/nasa/matlab/2017b/bin/matlab -nodisplay -nodesktop -nosplash -r "try;write_maiac_matlab_file_hourly([$year_i_maiac $month_i_maiac $day_i_maiac $hour_i_maiac 0 0],[$year_f $month_f $day_f $hour_f 0 0],'${path_maiac_data}/');catch;disp('MATLAB Issue');exit;end"
ENDF

   cmd="qsub write_maiac_matlab_file.sh"
   echo $cmd
   eval $cmd
   sleep 10
   echo 'Regridding MAIAC data...'
   status=`qstat -u ctrujil1 | grep maiac`
    while [ -n "$status" ] ;do
        sleep 5
        status=`qstat -u ctrujil1 | grep maiac`
    done
    echo 'Complete!'


# Run inversion
# -------------

cd ${path_matlab}

cat >compare_maiac_aod_submit.sh<< ENDF
#!/usr/bin/sh
#PBS -N invers
#PBS -l select=1:ncpu:1:model=bro
#PBS -l walltime=02:00:00
source /usr/share/modules/init/sh
module load matlab/2017b

cd ${path_matlab}
/nasa/matlab/2017b/bin/matlab -nodisplay -nodesktop -nosplash -r " \
addpath('./assimilation_tools/lbfgs_toronto/lbfgs'); \
addpath('./assimilation_tools/lbfgs_toronto/LHSutils'); \
try; compare_maiac_aod_gthomp_68tr_nonlog([$year_i $month_i $day_i $hour_i 0 0],[$year_f $month_f $day_f $hour_f 0 0],68,[$year_i $month_i $day_i $hour_i 0 0],[$year_i_maiac $month_i_maiac $day_i_maiac $hour_i_maiac 0 0], '${WRF_TRACER_OUT_week}/', '${WRF_NOFIRE_OUT_week}/', '${path_maiac_script}/data_saved/', '${FIRE_OUT_week}/', 'neighbor' ); \
catch;disp('MATLAB Issue!!!');exit;end"
ENDF

    cmd='qsub compare_maiac_aod_submit.sh'
    echo $cmd
    eval $cmd
    sleep 5
    echo "Waiting inversion to complete..."
    status=`qstat -u ctrujil1 | grep invers`
    while [ -n "$status" ] ;do
        sleep 5
        status=`qstat -u ctrujil1 | grep invers`
    done
    echo 'Complete inversion!'


# Create constrained emissions
# ----------------------------

    date_aux="${year_i}-${month_i}-${day_i} ${hour_i}:00:00"
    # compute final date of the forecast
    year_f2=$(date --date "$date_aux  ${timestep} hours" '+%Y')
    month_f2=$(date --date "$date_aux  ${timestep} hours" '+%m')
    day_f2=$(date --date "$date_aux  ${timestep} hours" '+%d')
    hour_f2=$(date --date "$date_aux  ${timestep} hours" '+%H')
    echo "Date end D01= ${year_f2}-${month_f2}-${day_f2}_${hour_f2}:00:00"

    # compute final date of the 8 Tracer
    year_f3=$(date --date "$date_aux  ${timestep_8tracer} hours" '+%Y')
    month_f3=$(date --date "$date_aux  ${timestep_8tracer} hours" '+%m')
    day_f3=$(date --date "$date_aux  ${timestep_8tracer} hours" '+%d')
    hour_f3=$(date --date "$date_aux  ${timestep_8tracer} hours" '+%H')
    echo "Date 8 Tracer= ${year_f3}-${month_f3}-${day_f3}_${hour_f3}:00:00"

  # copy wrffirechemi file
  for hour  in `seq 0 1 $timestep_8tracer`
  do
      time_str=`date -d "$year_i$month_i$day_i $hour_i  $hour hour" +"%Y-%m-%d_%H:00:00"`
      cp $FIRE_OUT_week/wrffirechemi_d01_${time_str} $FIRE_ANA_OUT_week/
  done

  # copy wrffirechemi file
  for hour  in `seq 0 1 $timestep`
  do
      time_str=`date -d "$year_i$month_i$day_i $hour_i  $hour hour" +"%Y-%m-%d_%H:00:00"`
      cp $FIRE_OUT_week/wrffirechemi_d01_${time_str} $FIRE_ANA_TRACER_OUT_week/
      ncks -A $path_matlab/wrffirechemi_d01_tracer8_base $FIRE_ANA_TRACER_OUT_week/wrffirechemi_d01_${time_str} 
  done


    # Run matlab script to scale emissions
cat <<ENDF > scale_fire_emissions_submit.sh 
#!/usr/bin/sh
#PBS -N scale
#PBS -l select=1:ncpu=1:model=bro
#PBS -l walltime=0:20:00
source /usr/share/modules/init/sh
module load matlab/2017b

cd ${path_matlab}
/nasa/matlab/2017b/bin/matlab -nodisplay -nodesktop -nosplash -r " \
cd ${path_matlab}; \
try;scale_fire_emissions_inversion_68tr_SkipLastDay_fn([$year_i $month_i $day_i $hour_i 0 0],[$year_f2 $month_f2 $day_f2 $hour_f2 0 0],[$year_i $month_i $day_i $hour_i 0 0],[$year_f $month_f $day_f $hour_f 0 0],[$year_i_maiac $month_i_maiac $day_i_maiac $hour_i_maiac 0 0],[$year_f $month_f $day_f $hour_f 0 0],${Ntracer1},'${FIRE_OUT_week}/','${FIRE_ANA_OUT_week}/','${WRF_TRACER_DIR}/wrfinput_d01','neighbor'); \
catch;disp('MATLAB Issue!!!');exit;end "
ENDF

    cmd="qsub scale_fire_emissions_submit.sh"
    echo $cmd
    eval $cmd
    sleep 5 
    status=`qstat -u ctrujil1 | grep scale`
    echo "Waiting: emissions scaling..."
    while [ -n "$status" ] ;do
        sleep 5
        status=`qstat -u ctrujil1 | grep scale`
    done
    echo 'Complete scale emissions!'


# Create tracers for forecast 
# ----------------------------

cat <<ENDF >create_tracer_emissions_8tr_submit.sh 
#!/usr/bin/sh
#PBS -N tracer
#PBS -l select=1:ncpu=1:model=bro
#PBS -l walltime=0:20:00
source /usr/share/modules/init/sh
module load matlab/2017b

cd ${path_matlab}
/nasa/matlab/2017b/bin/matlab -nodisplay -nodesktop -nosplash -r " \
try; create_tracer_emissions_8tr([$year_i $month_i $day_i $hour_i 0 0],[$year_f2 $month_f2 $day_f2 $hour_f2 0 0],[$year_i $month_i $day_i $hour_i 0 0],[$year_f3 $month_f3 $day_f3 $hour_f3 0 0],${Ntracer2},'${FIRE_ANA_OUT_week}/','${FIRE_ANA_TRACER_OUT_week}/','${input_path_anthro}/','${WRF_TRACER_DIR}/wrfinput_d01', 'neighbor' ); \
catch;disp('MATLAB Issue!!!');exit;end "
ENDF

    cmd="qsub create_tracer_emissions_8tr_submit.sh"
    echo $cmd
    eval $cmd
    sleep 5 
    status=`qstat -u ctrujil1 | grep tracer`
    echo "Waiting: creating tracers..."
    while [ -n "$status" ] ;do
        sleep 5
        status=`qstat -u ctrujil1 | grep tracer`
    done
    echo 'Complete creating tracers!'

   # change permission 
   cd ..
   /bin/chmod -R a+r ./

exit

