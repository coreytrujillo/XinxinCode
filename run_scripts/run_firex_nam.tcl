#!/usr/bin/wish -f
###############################################################################
#           run WRF forecast chain
#           - ftp gfs forecast
#           - WPS modules
#           - real.exe
#           - wrf.exe
#            Major modifications to suit present cases Pallavi Marrapu -2010, Pablo Saide -2012, Xinxin Ye 2019
#           Basic frame work by Alessio D'Allura - Arianet srl - 2008 
#
#  CHANGE BACK TIMESTEPS AND SCRIPT RUN WRF-GSI, TURN ON PLOT AND GFS
#
###############################################################################
#
## Test forecast for FIREX-AQ, by Xinxin Ye -2018
#
#working directory 
set HOME_DIR /home/xye/firechem/FIREX-AQ
set SCRIPT_DIR [file join $HOME_DIR run_scripts]
#set MOZ_DIR /glade/p/ral/nsap/saide/ORACLES_forecast_cheyenne/mozbc_vMACC_seac4rs
set FIRE_DIR [file join $HOME_DIR fire_emiss/conv_to_wrffire]
set FIRE_SCRIPT_DIR [file join $HOME_DIR fire_aod_scripts]
#set FIRE_FILE_DIR /glade/p/ral/nsap/saide/ORACLES_forecast_cheyenne/fire_aod_scripts/finn_download
set FIRE_QFED2_FILE_DIR [file join $FIRE_SCRIPT_DIR qfed2_download]
set NCL_SCRIPT_DIR [file join $HOME_DIR ncl_plots]
set JOINER_DIR [file join $HOME_DIR wrf_joiner/scripts]
set MATLAB_TRACER_DIR [file join $HOME_DIR matlab_scripts/tracers_smoke]
#
#
set WPS_DIR [file join $HOME_DIR WPS_run]
set WRF_TRACER_DIR [file join $HOME_DIR WRF_run/tracer]
set WRF_TRACER_OUT [file join $HOME_DIR wrfout/tracer]
set WRF_NOFIRE_DIR [file join $HOME_DIR WRF_run/nofire]
set WRF_NOFIRE_OUT [file join $HOME_DIR wrfout/nofire]
set WRF_ANALYSIS_DIR [file join $HOME_DIR WRF_run/analysis]
set WRF_ANALYSIS_OUT [file join $HOME_DIR wrfout/analysis]
set fire_qfed2_dir [file join $HOME_DIR input/fire_qfed2]
set anthro_emis_dir [file join $HOME_DIR input/anthro_emis]
set fnl_dir [file join $HOME_DIR input/FNL]
set gfs_dir [file join $HOME_DIR input/GFS]
set nam_anl_dir [file join $HOME_DIR input/NAM_anl]
set nam_fst_dir [file join $HOME_DIR input/NAM_fst]
set maiac_dir [file join $HOME_DIR input/MAIAC]
set abi_dir [file join $HOME_DIR input/ABI]
set viirs_dir [file join $HOME_DIR input/VIIRS]
set nnr_dir [file join $HOME_DIR input/NNR]
set NNR_SCRIPT [file join $HOME_DIR matlab_scripts/NNR_read_package]
set MAIAC_SCRIPT [file join $HOME_DIR matlab_scripts/MAIAC_read_package]

set 1proc_cmd "qsub -N matlab -l select=1:ncpus=1:model=bro -l walltime=01:00:00"

cd $SCRIPT_DIR
#tcl sources files
source [file join $SCRIPT_DIR  utility.tcl]
source [file join $SCRIPT_DIR  google.tcl]


#DO A PORTION
# To use FNL and GFS data for meteorology, set both fnl and gfs to "yes"
# FNL analysis data and GFS forecast data will be downloaded 
set fnl "no"   
set gfs "no"
# To use NAM data for meteorology, set nam to yes 
# NAM analysis and forecast data will be downloaded 
set nam "no"
set maiac "no"
set nnr "no"
set abi "no"
set viirs "no"
set wps  "no"
set real  "no"
set fire_qfed2 "no"  
set rst_ic "no"
set wrf_part1 "yes"
set wait_data "no"
set wrf_part2 "yes"
set wrf_part3 "yes"

# define SIMULATION LENGHT hours
 set timestep 150
 set timestep_gfs 96
 set timestep_fnl 84
 set timestep_nam_fst 84
 set timestep_nam_anl 66
 set timestep_tracer 88
 set timestep_nofire 88
 set timestep_8tracer 150


#define start date
set data1 "20190804"
# define SIMULATION START hour
set shh 06
# DEFINE gfs forecast 
set gfs_run 12

if { $data1 > 0} {
   set data [string range $data1 0 3]
   lappend data [string range $data1 4 5]
   lappend data [string range $data1 6 7]
   } else {
   set secondi [clock seconds]
   #EDT to UTC: +4 hours  
   set secondi [expr $secondi + 3600*4]  
   set data [split [clock format $secondi -format %Y:%m:%d] ":"]
   }

set saaaa [lindex $data 0]
set smm   [lindex $data 1]
set sdd   [lindex $data 2]
set week $saaaa$smm$sdd

append datafin [lindex $data 0] [lindex $data 1] [lindex $data 2]
#set datafin [expr [clock scan $datafin]+[expr $shh*3600]+[expr $timestep_nofire*3600]]
set datafin [expr [clock scan $datafin]+[expr $timestep_nam_fst*3600]]
set eaaaa [clock format $datafin -format %Y]
set emm   [clock format $datafin -format %m]
set edd   [clock format $datafin -format %d]
set ehh   [clock format $datafin -format %H]


#set dates
set datafire [expr [clock scan $saaaa$smm$sdd]+($shh*3600)-(24*3600*3)]
set fire_aaaa [clock format $datafire -format %Y]
set fire_mm [clock format $datafire -format %m]
set fire_dd [clock format $datafire -format %d]
set fire_hh [clock format $datafire -format %H]

set datawrf [expr [clock scan $saaaa$smm$sdd]+($shh*3600)-(24*3600*3)]
set wrf_aaaa [clock format $datawrf -format %Y]
set wrf_mm [clock format $datawrf -format %m]
set wrf_dd [clock format $datawrf -format %d]
set wrf_hh [clock format $datawrf -format %H]

#tracer
set dataf_tracer [expr [clock scan $wrf_aaaa$wrf_mm$wrf_dd]+[expr $shh*3600]+[expr $timestep_tracer*3600]]
set eaaaa_tracer [clock format $dataf_tracer -format %Y]
set emm_tracer [clock format $dataf_tracer -format %m]
set edd_tracer [clock format $dataf_tracer -format %d]
set ehh_tracer [clock format $dataf_tracer -format %H]


set WRF_TRACER_OUT_week [file join $WRF_TRACER_OUT $week]
set WRF_NOFIRE_OUT_week [file join $WRF_NOFIRE_OUT $week]
set WRF_ANALYSIS_OUT_week [file join $WRF_ANALYSIS_OUT $week]
set FIRE_OUT_week [file join $fire_qfed2_dir $week orig]
set FIRE_TRACER_OUT_week [file join $fire_qfed2_dir $week tracer68]
set FIRE_ANA_OUT_week [file join $fire_qfed2_dir $week constrained]
set FIRE_ANA_TRACER_OUT_week [file join $fire_qfed2_dir $week constrained_tracer8]


##############################################################################################################

#define procedure's log file
set flog [file join $SCRIPT_DIR run_[clock format [clock seconds] -format "%Y-%m-%d_%H:%M:%S" ]\.log]
set log [open $flog w+]

#create output directory
  if { ![file exists $WRF_TRACER_OUT_week]} {file mkdir $WRF_TRACER_OUT_week; file attributes $WRF_TRACER_OUT_week -permissions a+r;  puts $log "directory $WRF_TRACER_OUT_week made"}
  if { ![file exists $WRF_NOFIRE_OUT_week]} {file mkdir $WRF_NOFIRE_OUT_week; file attributes $WRF_NOFIRE_OUT_week -permissions a+r;  puts $log "directory $WRF_NOFIRE_OUT_week made"}
  if { ![file exists $WRF_ANALYSIS_OUT_week]} {file mkdir $WRF_ANALYSIS_OUT_week; file attributes $WRF_ANALYSIS_OUT_week -permissions a+r;  puts $log "directory $WRF_ANALYSIS_OUT_week made"}


# download FNL
if { $fnl == "yes" } {
puts $log "# ---------------------------------------------------------"
puts $log "# get FNL forecat fields grib version 2 format"
puts $log "# from ftp.ncep.noaa.gov FTP ncep distribution site"
puts $log "# ---------------------------------------------------------"

cd $HOME
  set c [catch { eval "exec ssh localhost \"$SCRIPT_DIR/download_fnl.sh ${wrf_aaaa}${wrf_mm}${wrf_dd}${wrf_hh} ${timestep_fnl} 3 ${fnl_dir}\"" } msg ]
  puts $log $msg
  flush $log
}

# download GFS
if { $gfs == "yes" } {
puts $log "# ---------------------------------------------------------"
puts $log "# get GFS forecat fields grib version 2 format"
puts $log "# from tgftp.nws.noaa.gov FTP ncep distribution site"
puts $log "# ---------------------------------------------------------"

  # set ftp variables
#  # DEFINE forecast start
#  set address  tgftp.nws.noaa.gov
#  set user anonymous
#  set pass cgrer
#  set remdir SL.us008001/ST.opnl/MT.gfs_CY.$gfs_run\/RD.$week\/PT.grid_DF.gr2

  set address  ftp.ncep.noaa.gov
  set user anonymous
  set pass cgrer
  set remdir pub/data/nccf/com/gfs/prod/gfs.${week}/${gfs_run}

  # check destination folder
  set METEO_INP [file join $gfs_dir $week\_$gfs_run]
  if { ![file exists $METEO_INP]} {file mkdir $METEO_INP; file attributes $METEO_INP -permissions a+rx;  puts $log "directory $METEO_INP made"}

  # dowload files
  set fore_step [expr $timestep_gfs+12]
  puts $log "fore_step $fore_step"

  for {set i 0} {$i <= $fore_step} {incr i 3} {
     # METEO file name
     set F_INP gfs.t${gfs_run}z.pgrb2.0p25.f[format "%03u" $i] 
     puts $log "Looking for $F_INP"
     if { ![file exists [file join $METEO_INP $F_INP]]} {
        puts $log "get_gfs: $F_INP not yet present in local archive"
	flush $log
        puts $log $address
        puts $log $remdir
        puts $log $METEO_INP
        puts $log $F_INP
        set WGET_BIN [ file join / usr bin wget ]
        set WGET_LOG [ file join $METEO_INP wget_log_$F_INP ]
        set returnget [exec $::WGET_BIN -P $METEO_INP ftp://$address\/$remdir\/$F_INP >&$::WGET_LOG]
#        set returnget [exec /usr/bin/wget -nv --ftp-user=$user --ftp-password=$pass -P $METEO_INP ftp://$address\/$remdir\/$F_INP]
#        set returnget [get_ftp $address $user $pass $remdir $METEO_INP $F_INP]
        set returnget [catch { eval "exec ls $METEO_INP\/$F_INP" } msg ]
         puts $log $returnget
         puts $log $msg
         flush $log
#        puts $log "get_gfs (1 ok,0 no): $returnget"
        puts $log "get_gfs (0 ok,>0 no): $returnget"
        if { $returnget==0 } {
         puts $log "[clock format [clock seconds] -format "%H:%M:%S" ] |I| get_gfs: $F_INP download ok"
        } else {

           puts $log "[clock format [clock seconds] -format "%H:%M:%S" ] |E| get_gfs: $F_INP download error"
           puts $log "[clock format [clock seconds] -format "%H:%M:%S" ] |E| get_gfs: try later"
	   crontab_shell 1
           }
        }
     puts $log "[clock format [clock seconds] -format "%H:%M:%S" ] |I| get_gfs: $F_INP download ok"
     file attributes [file join $METEO_INP $F_INP] -permissions a+rx 
     }

  puts $log "[clock format [clock seconds] -format "%H:%M:%S" ] |I| get_gfs $week DONE "
} 


# download NNR
if { $nnr == "yes" } {
puts $log "# ---------------------------------------------------------"
puts $log "# get nnr data from NASA "
puts $log "# ---------------------------------------------------------"
  if { ![file exists $nnr_dir]} {file mkdir $nnr_dir; file attributes $nnr_dir -permissions a+rx;  puts $log "directory $nnr_dir made"}
  # download data
  foreach hour [exec seq 0 24 $timestep_tracer ] {
      set str [eval "exec date -d \"$wrf_aaaa$wrf_mm$wrf_dd $wrf_hh $hour hour\" +\"%Y%m%d\""]
      set date_str [string map {\" {}} $str]
      puts $log "downloading: $date_str"
      flush $log
      set c [catch { eval "exec $SCRIPT_DIR/download_nnr.sh ${date_str} ${nnr_dir}" } msg ]
      puts $log $msg
      flush $log
  }
}


# download MAIAC
if { $maiac == "yes" } {
puts $log "# ---------------------------------------------------------"
puts $log "# get maiac data from EARTHDATA, NASA"
puts $log "# ---------------------------------------------------------"
   if { ![file exists $maiac_dir]} {file mkdir $maiac_dir; file attributes $maiac_dir -permissions a+rx;  puts $log "directory $maiac_dir made"}

  # download data
  foreach hour [exec seq 0 24 $timestep_tracer ] {
      set str [eval "exec date -d \"$wrf_aaaa$wrf_mm$wrf_dd $wrf_hh $hour hour\" +\"%Y%m%d\""]
      set date_str [string map {\" {}} $str]
      puts $log "downloading: $date_str"
      flush $log
      set c [catch { eval "exec $SCRIPT_DIR/download_maiac.sh ${date_str} ${maiac_dir}" } msg ]
      puts $log $msg
      flush $log
  }
}

# download ABI AOD
if { $abi == "yes" } {
puts $log "# ---------------------------------------------------------"
puts $log "# get abi data from NOAA " 
puts $log "# ---------------------------------------------------------"
   if { ![file exists $abi_dir]} {file mkdir $abi_dir; file attributes $abi_dir -permissions a+rx;  puts $log "directory $abi_dir made"}

  # download data
  foreach hour [exec seq 0 24 $timestep_tracer ] {
      set str [eval "exec date -d \"$wrf_aaaa$wrf_mm$wrf_dd $wrf_hh $hour hour\" +\"%Y%m%d\""]
      set date_str [string map {\" {}} $str]
      puts $log "downloading: $date_str"
      flush $log
      set c [catch { eval "exec $SCRIPT_DIR/download_abi.sh ${date_str} ${abi_dir}" } msg ]
      puts $log $msg
      flush $log
  }
}

# download VIIRS AOD
if { $viirs == "yes" } {
puts $log "# ---------------------------------------------------------"
puts $log "# get VIIRS data from NOAA " 
puts $log "# ---------------------------------------------------------"
   if { ![file exists $viirs_dir]} {file mkdir $viirs_dir; file attributes $viirs_dir -permissions a+rx;  puts $log "directory $viirs_dir made"}

  # download data
  foreach hour [exec seq 0 24 $timestep_tracer ] {
      set str [eval "exec date -d \"$wrf_aaaa$wrf_mm$wrf_dd $wrf_hh $hour hour\" +\"%Y%m%d\""]
      set date_str [string map {\" {}} $str]
      puts $log "downloading: $date_str"
      flush $log
      set c [catch { eval "exec $SCRIPT_DIR/download_viirs.sh ${date_str} ${viirs_dir}" } msg ]
      puts $log $msg
      flush $log
  }
}

# download NAM data
if { $nam == "yes" } {
puts $log "# ---------------------------------------------------------"
puts $log "# Download NAM forecast data from NCEP data archive "
puts $log "# ---------------------------------------------------------"
   # forecast cycle: 00 UTC  
   set path_fst [file join $nam_fst_dir $week\_00]  
   set path_anl [file join $nam_anl_dir ]
   if { ![file exists $path_fst]} {file mkdir $path_fst; file attributes $path_fst -permissions a+rx;  puts $log "directory $path_fst made"}
   if { ![file exists $path_anl]} {file mkdir $path_anl; file attributes $path_anl -permissions a+rx;  puts $log "directory $path_anl made"}

   # download forecast data 
   set c [catch {eval "exec $SCRIPT_DIR/download_nam.sh ${week}00 ${timestep_nam_fst} 3 ${path_fst}"} msg ]
   puts $log $msg
   flush $log 
   
   # download analysis data, 00 hr analysis and 03 hr forecast to fulfill 3 hr interval
   set c [catch {eval "exec $SCRIPT_DIR/download_nam_anl.sh ${wrf_aaaa}${wrf_mm}${wrf_dd}${wrf_hh}  ${timestep_nam_anl} 6 ${path_anl}"} msg ]
   puts $log $msg
   flush $log 
}



#run WPS 
if { $wps == "yes" } {
puts $log "# ---------------------------------------------------------"
puts $log "# run WPS modules"
puts $log "# run link_grib.csh"
puts $log "# run ungrib.exe"
puts $log "# run metgrid.exe"
puts $log "# ---------------------------------------------------------"
flush $log

  cd $WPS_DIR
  #do some cleaning
  if {[llength [glob -nocomplain [file join SST*]]] > 0} {eval "file delete -force [glob -nocomplain [file join SST*]]"}
  if {[llength [glob -nocomplain [file join  FILE:*]]] > 0} {eval "file delete -force [glob -nocomplain [file join FILE:*]]"}
  if {[llength [glob -nocomplain [file join  GRIBFILE*]]] > 0} {eval "file delete -force [glob -nocomplain [file join GRIBFILE*]]"}
  if {[llength [glob -nocomplain [file join met_em.d*]]] > 0} {eval "file delete -force [glob -nocomplain [file join met_em.d*]]"}

  cd grib_files
  if {[llength [glob -nocomplain [file join gfs*]]] > 0} {eval "file delete -force [glob -nocomplain [file join gfs*]]"}
  if {[llength [glob -nocomplain [file join gdas*]]] > 0} {eval "file delete -force [glob -nocomplain [file join gdas*]]"}
  if {[llength [glob -nocomplain [file join *nam*]]] > 0} {eval "file delete -force [glob -nocomplain [file join *nam*]]"}
  cd $WPS_DIR

#  #link GFS
#  set gfs_f [glob -nocomplain [file join $gfs_dir $week\_$gfs_run gfs.*]]
#  foreach x $gfs_f {
#      exec ln -sf $x $WPS_DIR/grib_files/
#  }
# 
#  #link FNL
#  foreach hour [exec seq 0 6 $timestep_fnl ] {
#      set datanam [expr [clock scan $wrf_aaaa$wrf_mm$wrf_dd]+[expr $wrf_hh*3600]+[expr $hour*3600]] ;
#      set fnl_aaaa [clock format $datanam -format %Y]
#      set fnl_mm [clock format $datanam -format %m]
#      set fnl_dd [clock format $datanam -format %d]
#      set fnl_hh [clock format $datanam -format %H]
#      set fnl_f [glob -nocomplain [file join $fnl_dir gdas*$fnl_aaaa$fnl_mm$fnl_dd$fnl_hh*]] 
#      foreach x $fnl_f { exec ln -sf $x $WPS_DIR/grib_files/ }
#      
#  }
#  set c [catch { eval "exec ./link_grib.csh [file join grib_files \*]" } msg ]
#  if {$c == 1 && $msg != 0} {puts $log "[clock format [clock seconds] -format "%H:%M:%S" ] |E| Standard Error link_grib.csh:\n$msg"; END_shell 1}

  #link NAM forecast
  set gfs_f [glob -nocomplain [file join $nam_fst_dir $week\_00 *nam.*]]
  foreach x $gfs_f {
      exec ln -sf $x $WPS_DIR/grib_files/
  }
 
  #link NAM analysis
  foreach hour [exec seq 0 6 $timestep_fnl ] {
      set datanam [expr [clock scan $wrf_aaaa$wrf_mm$wrf_dd]+[expr $wrf_hh*3600]+[expr $hour*3600]] ;
      set nam_aaaa [clock format $datanam -format %Y]
      set nam_mm [clock format $datanam -format %m]
      set nam_dd [clock format $datanam -format %d]
      set nam_hh [clock format $datanam -format %H]
      set nam_f [glob -nocomplain [file join $nam_anl_dir $nam_aaaa$nam_mm${nam_dd}.nam.t${nam_hh}z.*]] 
      foreach x $nam_f { exec ln -sf $x $WPS_DIR/grib_files/ }
  }


  # link grib 
  set c [catch { eval "exec ./link_grib.csh [file join grib_files \*]" } msg ]

  set sedcommand [open sedcommand.sed w+]
  puts $sedcommand "s,_START_,$wrf_aaaa\-$wrf_mm\-$wrf_dd\_$wrf_hh:00:00,g"
  puts $sedcommand "s,_END_,$eaaaa\-$emm\-$edd\_$ehh\:00:00,g"
  close $sedcommand
  exec sed -f sedcommand.sed $SCRIPT_DIR/namelist.wps.sed  > namelist.wps
  file delete -force sedcommand.sed

#  exec ln -sf ungrib/Variable_Tables/Vtable.GFS_new Vtable
  set c [catch { eval "exec $WPS_DIR/ungrib.exe" } msg ]

  # run mod_levs 
  set command "exec qsub ./run_mod_levs_test.sh"
  set c [catch { eval $command } msg ] 
  puts $log "Waiting: mod_levs.exe"
  set c [catch {eval "exec qstat -u ctrujil1 | grep modlev"} status ]
  while { $c==0 } {
        exec sleep 5
        set c [catch {eval "exec qstat -u ctrujil1 | grep modlev"} status ]
    }
  puts $log "Complete mod_levs!"

  # run metgrid 
  set command "exec qsub ./run_metgrid_test.csh"
  set c [catch { eval $command } msg ] 
  puts $log "Waiting: metgrid.exe"
  set c [catch {eval "exec qstat -u ctrujil1 | grep metgrid"} status ]
  while { $c==0 } {
        exec sleep 5
        set c [catch {eval "exec qstat -u ctrujil1 | grep metgrid"} status ]
    }
  puts $log "Complete metgrid!"
}


# run real.exe
if { $real == "yes" } {
puts $log "# ---------------------------------------------------------"
puts $log "# run real.exe "
puts $log "# ---------------------------------------------------------"
flush $log

  cd $WRF_TRACER_DIR
  #do some cleaning
  if {[llength [glob -nocomplain met_em.d*]] > 0} {eval "file delete -force [glob -nocomplain met_em.d*]"}
  if {[llength [glob -nocomplain rsl.*]] > 0} {eval "file delete -force [glob -nocomplain rsl.*]"}
  if {[llength [glob -nocomplain  wrfout_d*]] > 0} {eval "file delete -force [glob -nocomplain  wrfout_d*]"}
  if {[llength [glob -nocomplain  wrfrst_d*]] > 0} {eval "file delete -force [glob -nocomplain  wrfrst_d*]"}
  if {[llength [glob -nocomplain  wrffirechemi_d*]] > 0} {eval "file delete -force [glob -nocomplain  wrffirechemi_d*]"}

  set sedcommand [open sedcommand.sed w+]
  puts $sedcommand "s,_steps_,$timestep,g"
  puts $sedcommand "s,_SAAAA1_,$wrf_aaaa,g"
  puts $sedcommand "s,_SMM1_,$wrf_mm,g"
  puts $sedcommand "s,_SDD1_,$wrf_dd,g"
  puts $sedcommand "s,_SHH1_,$wrf_hh,g"
  puts $sedcommand "s,_EAAAA1_,$eaaaa,g"
  puts $sedcommand "s,_EMM1_,$emm,g"
  puts $sedcommand "s,_EDD1_,$edd,g"
  puts $sedcommand "s,_EHH1_,$ehh,g"
  close $sedcommand
  exec sed -f sedcommand.sed $SCRIPT_DIR/namelist.input.real.sed  > namelist.input
  file delete -force sedcommand.sed

  #link met files
  set met_f [glob -nocomplain [file join $WPS_DIR met_em.d*]]
  foreach x $met_f {
        exec ln -sf $x .
        }

  # link first wrffire file for real.exe
#  set c [catch {eval "exec ln -sf wrffirechemi_d01_$wrf_aaaa\-$wrf_mm\-$wrf_dd\_$wrf_hh\:00:00 wrffirechemi_d01" } msg ]  

  # Submitt
 cd $WRF_TRACER_DIR
  set c [catch { eval "exec qsub $WRF_TRACER_DIR/run_real_test.csh"} msg ]
  puts $log $msg
  #check wrfinput-files are generated
  puts $log "Waiting: real.exe ... "
  set c [catch {eval "exec qstat -u ctrujil1 | grep real"} status ]
  while { $c==0 } {
        exec sleep 5
        set c [catch {eval "exec qstat -u ctrujil1 | grep real"} status ]
    }
  puts $log "wrf input file generated"
  flush $log 

  # Copy wrfinput and wrf_bdy to all runs
  set c [catch {eval "exec cp $WRF_TRACER_DIR/wrfinput_d01 $WRF_NOFIRE_DIR/" } msg ]
  set c [catch {eval "exec cp $WRF_TRACER_DIR/wrfbdy_d01 $WRF_NOFIRE_DIR/" } msg ]
  set c [catch {eval "exec cp $WRF_TRACER_DIR/wrffdda_d01 $WRF_NOFIRE_DIR/" } msg ]
  set c [catch {eval "exec cp $WRF_TRACER_DIR/wrfinput_d01 $WRF_ANALYSIS_DIR/" } msg ]
  set c [catch {eval "exec cp $WRF_TRACER_DIR/wrfbdy_d01 $WRF_ANALYSIS_DIR/" } msg ]
  set c [catch {eval "exec cp $WRF_TRACER_DIR/wrffdda_d01 $WRF_ANALYSIS_DIR/" } msg ]
}


#fire emissions processing 
if { $fire_qfed2 == "yes" } {
puts $log "# ---------------------------------------------------------"
puts $log "# run preprosses_qfed2_saprc99_emiss.m "
puts $log "# run fire_emis"
puts $log "# ---------------------------------------------------------"
flush $log

  #create fire directory
  if { ![file exists $FIRE_OUT_week]} {file mkdir $FIRE_OUT_week; file attributes $FIRE_OUT_week -permissions a+rx;  puts $log "directory $FIRE_OUT_week made"}
  if { ![file exists $FIRE_TRACER_OUT_week]} {file mkdir $FIRE_TRACER_OUT_week; file attributes $FIRE_TRACER_OUT_week -permissions a+rx;  puts $log "directory $FIRE_TRACER_OUT_week made"}
  if { ![file exists $FIRE_ANA_OUT_week]} {file mkdir $FIRE_ANA_OUT_week; file attributes $FIRE_ANA_OUT_week -permissions a+rx;  puts $log "directory $FIRE_ANA_OUT_week made"}
  if { ![file exists $FIRE_ANA_TRACER_OUT_week]} {file mkdir $FIRE_ANA_TRACER_OUT_week; file attributes $FIRE_ANA_TRACER_OUT_week -permissions a+rx;  puts $log "directory $FIRE_ANA_TRACER_OUT_week made"}


  # Copy fire emission files from discover. Downloading until the latest day, and link current day emissions to following forecast days 
  puts $log "# Download fire emission files"
  flush $log
  cd $FIRE_SCRIPT_DIR
  set c [catch { eval "exec $FIRE_SCRIPT_DIR/download_qfed2_saprc99_emiss.sh $FIRE_QFED2_FILE_DIR  $fire_aaaa$fire_mm$fire_dd$fire_hh $eaaaa$emm$edd$ehh > $FIRE_SCRIPT_DIR/download_qfed2_log" } msg ]
  puts $log $msg
  flush $log


  # Concatenate and fill fire emissions
  puts $log "# Concatenate and fill fire emissions "
  flush $log
  cd $FIRE_SCRIPT_DIR
  puts $log "exec $1proc_cmd \"${FIRE_SCRIPT_DIR}/preprosses_qfed2_saprc99_emiss.sh $FIRE_SCRIPT_DIR $fire_aaaa$fire_mm$fire_dd$fire_hh $eaaaa$emm$edd$ehh\" "
  flush $log
  set c [catch { eval "exec $1proc_cmd ${FIRE_SCRIPT_DIR}/preprosses_qfed2_saprc99_emiss.sh $FIRE_SCRIPT_DIR $fire_aaaa$fire_mm$fire_dd$fire_hh $eaaaa$emm$edd$ehh" } msg ]
  puts $log $msg
  flush $log

  puts $log "Waiting: concatenate fire emissions ... "
  set c [catch {eval "exec qstat -u ctrujil1 | grep matlab"} status ]
  while { $c==0 } {
        exec sleep 5
        set c [catch {eval "exec qstat -u ctrujil1 | grep matlab"} status ]
    }
  puts $log "finish"
  flush $log 


  # move files
  puts $log "# Move files "
  flush $log
  set c [catch {eval "exec  mv $FIRE_QFED2_FILE_DIR\/QFED_in_FINN_format_REDHC_pm10_$fire_aaaa$fire_mm$fire_dd$fire_hh\_$eaaaa$emm$edd$ehh\.txt $fire_qfed2_dir" } msg ]

  # modify namelist
  cd $FIRE_DIR
  set sedcommand [open sedcommand.sed w+]
  puts $sedcommand "s,_START_,$fire_aaaa$fire_mm$fire_dd$fire_hh,g"
  puts $sedcommand "s,_END_,$eaaaa$emm$edd$ehh,g"
  puts $sedcommand "s,_START2_,$fire_aaaa\-$fire_mm\-$fire_dd,g"
  puts $sedcommand "s,_END2_,$eaaaa\-$emm\-$edd,g"
  puts $sedcommand "s,_WRF_DIR_,$FIRE_DIR,g"
  puts $sedcommand "s,_fire_dir_,$fire_qfed2_dir,g"
  close $sedcommand
  exec sed -f sedcommand.sed fire_emis.redhc.KORUS_qfed_pm10.sed  > fire_emis.inp
  file delete -force sedcommand.sed

  # run fire_emiss
  puts $log "# Run fire_emiss "
  set c [catch {eval "exec rm $FIRE_DIR/wrfinput_d01" } msg ]
  set c [catch {eval "exec ln -s $WRF_TRACER_DIR/wrfinput_d01 $FIRE_DIR/wrfinput_d01" } msg ]
  set c [catch { eval "exec qsub \"run.csh\" >& fire_emis.log" } msg ]
  puts $log $msg
  puts $log "Waiting: fire_emiss ... "
  set c [catch {eval "exec qstat -u ctrujil1 | grep fire"} status ]
  while { $c==0 } {
        exec sleep 5
        set c [catch {eval "exec qstat -u ctrujil1 | grep fire"} status ]
    }
  puts $log "wrffirechemi files generated"
  flush $log 


  #do some cleaning
  cd $FIRE_OUT_week 
  if {[llength [glob -nocomplain wrffirechemi_d*]] > 0} {eval "file delete -force [glob -nocomplain wrffirechemi_d*]"}
  # move files to fire folder
  set fire_f [glob -nocomplain [file join $FIRE_DIR wrffirechemi_d*]]
   foreach x $fire_f {
    exec mv $x $FIRE_OUT_week/
  }
  puts $log "Moved wrffirechemi_d01* to FIRE folder"
  flush $log

  # append vars to wrffirechemi file
  foreach hour [exec seq 0 1 $timestep_tracer ] {
      set time_str [eval "exec date -d \"$wrf_aaaa$wrf_mm$wrf_dd $wrf_hh $hour hour\" +\"%Y-%m-%d_%H:00:00\""]
      set stripped [string map {\" {}} $time_str]
      exec cp $FIRE_OUT_week/wrffirechemi_d01_${stripped} $FIRE_TRACER_OUT_week/
      set x $FIRE_TRACER_OUT_week/wrffirechemi_d01_${stripped}
      # append tracer emission vars   
      set c [catch {eval "exec ncks -A $MATLAB_TRACER_DIR/wrffirechemi_d01_tracer68_base $x" } msg ] 
  }

  # create tracers
  cd ${MATLAB_TRACER_DIR}
  set mfile [open create_tracer_emissions_68tr_submit.m  w+]
  puts $mfile "cd ${MATLAB_TRACER_DIR}"
  puts $mfile "create_tracer_emissions_68tr_region(\[$wrf_aaaa $wrf_mm $wrf_dd $wrf_hh 0 0],\[$eaaaa_tracer $emm_tracer $edd_tracer $ehh_tracer 0 0],\[$wrf_aaaa $wrf_mm $wrf_dd $wrf_hh 0 0],\[$eaaaa_tracer $emm_tracer $edd_tracer $ehh_tracer  0 0],68,'${FIRE_OUT_week}/','${FIRE_TRACER_OUT_week}/','${anthro_emis_dir}/','${WRF_TRACER_DIR}/wrfinput_d01','neighbor');"
  puts $mfile  "exit;"
  close $mfile 
  set c [catch {eval "exec qsub \"create_tracer_emissions.sh\" "} msg ]
  puts $log $msg

  puts $log "Waiting: create 68 tracers ..."
  flush $log 
  set c [catch {eval "exec qstat -u ctrujil1 | grep etracer"} status ]
  while { $c==0 } {
        exec sleep 5
        set c [catch {eval "exec qstat -u ctrujil1 | grep etracer"} status ]
    }
  puts $log "Complete create tracers!"
  flush $log 
}



if { $rst_ic == "yes" } {
puts $log "# ---------------------------------------------------------"
puts $log "# Copy data from previous run"
puts $log "# ---------------------------------------------------------"
flush $log


# replace tracers for tracer run 
cd $WRF_TRACER_DIR
for {set skip_day 1} {$skip_day<5} {incr skip_day} {
   # set datarst [expr [clock scan $saaaa$smm$sdd]+($gfs_run*3600)-(24*3600*$skip_day)]
    set datarst [expr [clock scan $week ]+($shh*3600)-(24*3600*$skip_day)]
    set rst_aaaa [clock format $datarst -format %Y]
    set rst_mm [clock format $datarst -format %m]
    set rst_dd [clock format $datarst -format %d]
    set rst_hh [clock format $datarst -format %H]
    set week_rst $rst_aaaa$rst_mm$rst_dd
    set wrfrst_file1 [file join $WRF_TRACER_OUT $week_rst wrfout_d01_$wrf_aaaa\-$wrf_mm\-$wrf_dd\_$wrf_hh\:00:00]
    set wrfinput_file1 [file join $WRF_TRACER_DIR wrfinput_d01]

    if { [file exists $wrfrst_file1] } {
           break
    }
}

if {$skip_day==5} {
   puts $log "Restart file not found, NOT ADDING INITIAL CONDITIONS"
} else {
   puts $log "Restart file found in cycle of: $week_rst"
   cd $MATLAB_TRACER_DIR
   set c [catch {eval "exec $1proc_cmd restart_tracers_68tr_submit.sh ${MATLAB_TRACER_DIR} ${wrfrst_file1} ${wrfinput_file1}"} msg ]
  puts $log $msg
  flush $log
  puts $log "Waiting: replace 68 tracers"
  set c [catch {eval "exec qstat -u ctrujil1 | grep matlab"} status ]
  while { $c==0 } {
        exec sleep 5
        set c [catch {eval "exec qstat -u ctrujil1 | grep matlab"} status ]
    }
  puts $log "Complete replace tracers!"

}


# replace tracers for nofire run 

cd $WRF_NOFIRE_DIR
for {set skip_day 0} {$skip_day<5} {incr skip_day} {
    set datarst [expr [clock scan $week ]+($shh*3600)-(24*3600*$skip_day)]
    set rst_aaaa [clock format $datarst -format %Y]
    set rst_mm [clock format $datarst -format %m]
    set rst_dd [clock format $datarst -format %d]
    set rst_hh [clock format $datarst -format %H]
    set week_rst $rst_aaaa$rst_mm$rst_dd
    set wrfrst_file1 [file join $WRF_NOFIRE_OUT $week_rst wrfout_d01_$wrf_aaaa\-$wrf_mm\-$wrf_dd\_$wrf_hh\:00:00]
    set wrfinput_file1 [file join $WRF_NOFIRE_DIR wrfinput_d01]
    if { [file exists $wrfrst_file1] } {
           break
    }
}

if {$skip_day==5} {
   puts $log "Restart file not found, NOT ADDING INITIAL CONDITIONS"
} else {
   puts $log "Restart file found in cycle of: $week_rst"
   cd $MATLAB_TRACER_DIR
   set c [catch {eval "exec $1proc_cmd restart_tracers_nofire_submit.sh ${MATLAB_TRACER_DIR} ${wrfrst_file1} ${wrfinput_file1}"} msg ]
  puts $log $msg
  flush $log
  puts $log "Waiting: replace wrfinput ... "
  set c [catch {eval "exec qstat -u ctrujil1 | grep matlab"} status ]
  while { $c==0 } {
        exec sleep 5
        set c [catch {eval "exec qstat -u ctrujil1 | grep matlab"} status ]
    }
  puts $log "Complete replace wrfinput! "
}
} 
# end of rst


# run WRF tracer and nofire 
if { $wrf_part1 == "yes" } {
puts $log "# ---------------------------------------------------------"
puts $log "# run wrf part1"
puts $log "# ---------------------------------------------------------"
flush $log

  # clean WRF dir
  cd $WRF_TRACER_DIR
  if {[llength [glob -nocomplain wrffirechemi_d*]] > 0} {eval "file delete -force [glob -nocomplain wrffirechemi_d*]"}

  # Link fire files to WRF directory
  set fire_f [glob -nocomplain [file join $FIRE_TRACER_OUT_week wrffirechemi_d*]]
   foreach x $fire_f {
    exec ln -sf $x $WRF_TRACER_DIR/
  }
  puts $log "Linked wrffirechemi_D01 to WRF folder for tracer run"

  cd $SCRIPT_DIR
  set c [catch { eval "exec $SCRIPT_DIR/run_wrf_tracer_inversion_part1.sh $wrf_aaaa $wrf_mm $wrf_dd $wrf_hh $timestep_tracer $timestep_nofire $timestep $timestep_8tracer ${WRF_TRACER_DIR} ${WRF_NOFIRE_DIR} ${WRF_ANALYSIS_DIR} ${WRF_TRACER_OUT_week} ${WRF_NOFIRE_OUT_week} ${WRF_ANALYSIS_OUT_week} ${FIRE_OUT_week} ${FIRE_ANA_OUT_week} ${FIRE_ANA_TRACER_OUT_week} ${anthro_emis_dir} ${WRF_TRACER_DIR} ${SCRIPT_DIR} ${MATLAB_TRACER_DIR} ${maiac_dir} ${MAIAC_SCRIPT} ${JOINER_DIR} 68 8" } msg ]
  puts $log $msg
  flush $log
}


# wait to make sure the latest satellite AOD data are downloaded 
if { $wait_data == "yes" } { 
  puts $log "Waiting: wait till 03:16 EDT to start inversion"
  flush $log
  set c [catch {eval "exec date +%H%M"} msg ]
  while { $msg<0316 } {
        puts $log $msg
        exec sleep 5
        set c [catch {eval "exec date +%H%M"} msg ]
    }
}

#run inversion 
if { $wrf_part2 == "yes" } {
puts $log "# ---------------------------------------------------------"
puts $log "# run wrf part2"
puts $log "# ---------------------------------------------------------"
flush $log

  cd $SCRIPT_DIR
  set c [catch { eval "exec $SCRIPT_DIR/run_wrf_tracer_inversion_part2.sh $wrf_aaaa $wrf_mm $wrf_dd $wrf_hh $timestep_tracer $timestep_nofire $timestep $timestep_8tracer ${WRF_TRACER_DIR} ${WRF_NOFIRE_DIR} ${WRF_ANALYSIS_DIR} ${WRF_TRACER_OUT_week} ${WRF_NOFIRE_OUT_week} ${WRF_ANALYSIS_OUT_week} ${FIRE_OUT_week} ${FIRE_ANA_OUT_week} ${FIRE_ANA_TRACER_OUT_week} ${anthro_emis_dir} ${WRF_TRACER_DIR} ${maiac_dir} ${MAIAC_SCRIPT} ${MATLAB_TRACER_DIR}  ${JOINER_DIR} 68 8" } msg ]
  puts $log $msg
  flush $log
}



# run analysis and forecast 
if { $wrf_part3 == "yes" } {
puts $log "# ---------------------------------------------------------"
puts $log "# run wrf part3"
puts $log "# ---------------------------------------------------------"
flush $log

  cd $SCRIPT_DIR

  set c [catch { eval "exec $SCRIPT_DIR/run_wrf_tracer_inversion_part3.sh $wrf_aaaa $wrf_mm $wrf_dd $wrf_hh $timestep_tracer $timestep_nofire $timestep $timestep_8tracer ${WRF_TRACER_DIR} ${WRF_NOFIRE_DIR} ${WRF_ANALYSIS_DIR} ${WRF_TRACER_OUT_week} ${WRF_NOFIRE_OUT_week} ${WRF_ANALYSIS_OUT_week} ${FIRE_OUT_week} ${FIRE_ANA_OUT_week} ${FIRE_ANA_TRACER_OUT_week} ${anthro_emis_dir} ${WRF_TRACER_DIR} ${SCRIPT_DIR} ${MATLAB_TRACER_DIR} ${maiac_dir} ${MAIAC_SCRIPT} ${JOINER_DIR} 68 8" } msg ]
  puts $log $msg
  flush $log

  cd $SCRIPT_DIR
}



