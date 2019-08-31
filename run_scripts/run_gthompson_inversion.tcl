#!/usr/bin/wish -f
###############################################################################
#           run WRF forecast chain
#           - ftp gfs forecast
#           - WPS modules
#           - real.exe
#           - wrf.exe
#           - edit kml file for Google Earth
#            Major modifications to suit present cases Pallavi Marrapu -2010, Pablo Saide -2012
#           Basic frame work by Alessio D'Allura - Arianet srl - 2008 
#
#  CHANGE BACK TIMESTEPS AND SCRIPT RUN WRF-GSI, TURN ON PLOT AND GFS
#
###############################################################################

#working directory 
set HOME_DIR /glade/p/ral/nsap/saide/ORACLES_forecast_cheyenne
set SCRIPT_DIR /glade/p/ral/nsap/saide/ORACLES_forecast_cheyenne/run_scripts 
set MOZ_DIR /glade/p/ral/nsap/saide/ORACLES_forecast_cheyenne/mozbc_vMACC_seac4rs
set FIRE_DIR /glade/p/ral/nsap/saide/ORACLES_forecast_cheyenne/fire_emis/test
set FIRE_SCRIPT_DIR /glade/p/ral/nsap/saide/ORACLES_forecast_cheyenne/fire_aod_scripts
set FIRE_FILE_DIR /glade/p/ral/nsap/saide/ORACLES_forecast_cheyenne/fire_aod_scripts/finn_download
set FIRE_QFED2_FILE_DIR /glade/p/ral/nsap/saide/ORACLES_forecast_cheyenne/fire_aod_scripts/qfed2_download
set NCL_SCRIPT_DIR /glade/p/ral/nsap/saide/ORACLES_forecast_cheyenne/ncl_plots
set JOINER_DIR /glade/p/ral/nsap/saide/ORACLES_forecast_cheyenne/joiner_wrfinput
set CGRER_HTML_DIR /acomstaff/saide/oracles
set WEBPAGE_DIR /glade/p/ral/nsap/saide/ORACLES_forecast_cheyenne/webpage
set WEBPAGE_OTHER_DIR /glade/p/ral/nsap/saide/ORACLES_forecast_cheyenne/website_other_models
set MATLAB_TRACER_DIR /glade/p/ral/nsap/saide/ORACLES_forecast_cheyenne/matlab_scripts/tracers_smoke
set MATLAB_OTHER_DIR /glade/p/ral/nsap/saide/ORACLES_forecast_cheyenne/matlab_other_models
#set MATLAB_DIR /Shared/CGRER-Scratch/pablo_share/KORUS-AQ/forecast/matlab_scripts
#set GOCI_STORE_DIR /Shared/CGRER-Scratch/pablo_share/KORUS-AQ/forecast/input/goci
#set GOCI_SCRIPT_TEXT_DIR /Shared/CGRER-Scratch/pablo_share/KORUS-AQ/forecast/matlab_scripts/GOCI_read_package 
#set GOCI_SCRIPT_BUFR_DIR /Shared/CGRER-Scratch/pablo_share/KORUS-AQ/forecast/GSI_code/modis_aod_hdf2bufr_distrib_NRL_GMAO/run_goci
set NNR_STORE_DIR /glade/p/ral/nsap/saide/ORACLES_forecast_cheyenne/input/nnr
set NNR_SCRIPT /glade/p/ral/nsap/saide/ORACLES_forecast_cheyenne/matlab_scripts/NNR_read_package
#set NNR_SCRIPT_BUFR_DIR /Shared/CGRER-Scratch/pablo_share/KORUS-AQ/forecast/GSI_code/modis_aod_hdf2bufr_distrib_NRL_GMAO/run_gmao

set qsub_1proc_cmd "qsub -W block=true -A NSAP0003 -l select=1:ncpus=1:mpiprocs=1 -N matlab -j oe -l walltime=01:00:00 -q regular --"

cd $HOME_DIR
cd $SCRIPT_DIR
#tcl sources files
source [file join $SCRIPT_DIR  utility.tcl]
source [file join $SCRIPT_DIR  google.tcl]

#other variables
#DO ALL
set mail "no"
set copy_delete "no"
set fnl "no"
set gfs "no"
set fnl_nitro "yes"
set gfs_nitro "yes"
set wps  "yes"
set fire "no"
set fire_qfed2 "yes"
set real  "yes"
set macc "no"
set rst_ic "yes"
set wrf_part1 "yes"
set wrf_part2 "yes"
set wrf_part3 "yes"
set ncl_plot "yes"
set google  "no"

#DO A PORTION
#set mail "no"
#set copy_delete "no"
#set fnl "no"
#set gfs "no"
#set fnl_nitro "no"
#set gfs_nitro "no"
#set wps  "no"
#set fire "no"
#set fire_qfed2 "no"
#set real  "no"
#set macc "no"
##set rst_ic "no"
#set wrf_part1 "no"
#set wrf_part2 "yes"
#set wrf_part3 "yes"
#set ncl_plot "yes"
#set google  "no"

#DO ONE
#set mail "no"
#set copy_delete "no"
#set fnl "no"
#set gfs "no"
#set fnl_nitro "no"
#set gfs_nitro "no"
#set wps  "no"
#set fire "no"
#set fire_qfed2 "no"
#set real  "no"
#set macc "no"
#set rst_ic "no"
#set wrf_part1 "yes"
#set wrf_part2 "no"
#set wrf_part3 "no"
#set ncl_plot "no"
#set google  "no"

# set local work variables
set gfs_dir [file join $HOME_DIR input/gfs]
set fnl_dir [file join $HOME_DIR input/fnl]
set macc_dir [file join $HOME_DIR input/macc]
set fire_dir [file join $HOME_DIR input/fire]
set fire_qfed2_dir [file join $HOME_DIR input/fire_qfed2]
set anthro_emis_dir [file join $HOME_DIR emissions_anthro/epres_edgar_htap]

# set local work variables
#set WPS_DIR [file join $HOME_DIR WPS_3.6.1_run1]
set WPS_DIR [file join $HOME_DIR WPS_3.6.1_v3.9ungrib_run1]
# set local work variables
set MPD_ROOT "/usr/bin"
set ftp "/usr/bin"
#set MPI_ROOT "/usr/local/src/mpich2-1.0.6/bin"
set WRF_TRACER_DIR [file join $HOME_DIR WRF_v3.6.1_chem_tracer68_run1]
set WRF_TRACER_OUT [file join $HOME_DIR output_tracer]
set WRF_NOFIRE_DIR [file join $HOME_DIR WRF_v3.6.1_chem_tracer90_run2]
set WRF_NOFIRE_OUT [file join $HOME_DIR output_nofire]
set WRF_ANALYSIS_DIR [file join $HOME_DIR WRF_v3.6.1_chem_tracer16_run1]
set WRF_ANALYSIS_OUT [file join $HOME_DIR output_analysis]

# -------------------------------------------------------
# define start/end date
# the starting date is given by the system clock if data1 is empty
# ---------------------------------------------------------

# define SIMULATION LENGHT hours
 set timestep 180
 set timestep_gfs 96
 set timestep_fnl 84
 set timestep_tracer 88
 set timestep_nofire 96
 set timestep_16tracer 168

# set dt_fnl 3 
# set steps_fnl [expr $timestep_fnl/$dt_fnl]

# define SIMULATION START hour
set shh 00

# DEFINE gfs forecast 
set gfs_run 12

#define yout start time ddmmaaaahh
#set data1 "08072009"
#set data1 "08082013"
#set data1 "19092015"
#set data1 "20092015"
#set data1 "02072017"
#set data1 "13072017"
#set data1 "17072017"
#set data1 "19072017"
#set data1 "27072017"
set data1 "" 
if { $data1 > 0} {
   set data [string range $data1 4 7]
   lappend data [string range $data1 2 3]
   lappend data [string range $data1 0 1]
   } else {
   set secondi [clock seconds]
   set data [split [clock format $secondi -format %Y:%m:%d] ":"]
   }

set saaaa [lindex $data 0]
set smm   [lindex $data 1]
set sdd   [lindex $data 2]

append datafin [lindex $data 0] [lindex $data 1] [lindex $data 2]
#set datafin [expr [clock scan $datafin]+[expr $shh*3600]+[expr $timestep*3600]]
set datafin [expr [clock scan $datafin]+[expr $gfs_run*3600]+[expr $timestep_gfs*3600]]
set eaaaa [clock format $datafin -format %Y]
set emm   [clock format $datafin -format %m]
set edd   [clock format $datafin -format %d]
set ehh   [clock format $datafin -format %H]

set week $saaaa$smm$sdd

#######Editted to run wrfrst files###########
set datarst [expr [clock scan $saaaa$smm$sdd]+($gfs_run*3600)-(24*3600)]
set rst_aaaa [clock format $datarst -format %Y]
set rst_mm [clock format $datarst -format %m]
set rst_dd [clock format $datarst -format %d]
set rst_hh [clock format $datarst -format %H]
set week_rst $rst_aaaa$rst_mm$rst_dd

set datarst [expr [clock scan $saaaa$smm$sdd]+($gfs_run*3600)-(24*3600*2)]
set rst_aaaa_skip1 [clock format $datarst -format %Y]
set rst_mm_skip1 [clock format $datarst -format %m]
set rst_dd_skip1 [clock format $datarst -format %d]
set rst_hh_skip1 [clock format $datarst -format %H]
set week_rst_skip1 $rst_aaaa_skip1$rst_mm_skip1$rst_dd_skip1

set datarst [expr [clock scan $saaaa$smm$sdd]+($gfs_run*3600)-(24*3600*3)]
set rst_aaaa_skip2 [clock format $datarst -format %Y]
set rst_mm_skip2 [clock format $datarst -format %m]
set rst_dd_skip2 [clock format $datarst -format %d]
set rst_hh_skip2 [clock format $datarst -format %H]
set week_rst_skip2 $rst_aaaa_skip2$rst_mm_skip2$rst_dd_skip2

set datarst [expr [clock scan $saaaa$smm$sdd]+($gfs_run*3600)-(24*3600*4)]
set rst_aaaa_skip3 [clock format $datarst -format %Y]
set rst_mm_skip3 [clock format $datarst -format %m]
set rst_dd_skip3 [clock format $datarst -format %d]
set rst_hh_skip3 [clock format $datarst -format %H]
set week_rst_skip3 $rst_aaaa_skip3$rst_mm_skip3$rst_dd_skip3

set datarst [expr [clock scan $saaaa$smm$sdd]+($gfs_run*3600)-(24*3600*5)]
set rst_aaaa_skip4 [clock format $datarst -format %Y]
set rst_mm_skip4 [clock format $datarst -format %m]
set rst_dd_skip4 [clock format $datarst -format %d]
set rst_hh_skip4 [clock format $datarst -format %H]
set week_rst_skip4 $rst_aaaa_skip4$rst_mm_skip4$rst_dd_skip4

##########Eddited to download macc conditionds ######
set datamac [expr [clock scan $saaaa$smm$sdd]+($shh*3600)-(24*3600*2)]
#set datamac [expr [clock scan $saaaa$smm$sdd]+($shh*3600)-(24*3600)]
set mac_aaaa [clock format $datamac -format %Y]
set mac_mm [clock format $datamac -format %m]
set mac_dd [clock format $datamac -format %d]
set mac_hh [clock format $datamac -format %H]
set week_mac $mac_aaaa$mac_mm$mac_dd

set datamac_old [expr [clock scan $saaaa$smm$sdd]+($shh*3600)-(24*3600*3)]
set macold_aaaa [clock format $datamac_old -format %Y]
set macold_mm [clock format $datamac_old -format %m]
set macold_dd [clock format $datamac_old -format %d]
set macold_hh [clock format $datamac_old -format %H]
set week_macold $macold_aaaa$macold_mm$macold_dd

##########Eddited to download fires ######
#set datafire [expr [clock scan $saaaa$smm$sdd]+($shh*3600)-(24*3600*2)]
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
set week_wrf $wrf_aaaa$wrf_mm$wrf_dd

# get all dates for FNL for linking
set datafnl [expr [clock scan $saaaa$smm$sdd]+($shh*3600)-(24*3600*3)]
set fnl_aaaa [clock format $datafnl -format %Y]
set fnl_mm [clock format $datafnl -format %m]
set fnl_dd [clock format $datafnl -format %d]
set fnl_hh [clock format $datafnl -format %H]
set week_fnl1 $fnl_aaaa$fnl_mm$fnl_dd
set datafnl [expr [clock scan $saaaa$smm$sdd]+($shh*3600)-(24*3600*2)]
set fnl_aaaa [clock format $datafnl -format %Y]
set fnl_mm [clock format $datafnl -format %m]
set fnl_dd [clock format $datafnl -format %d]
set fnl_hh [clock format $datafnl -format %H]
set week_fnl2 $fnl_aaaa$fnl_mm$fnl_dd
set datafnl [expr [clock scan $saaaa$smm$sdd]+($shh*3600)-(24*3600*1)]
set fnl_aaaa [clock format $datafnl -format %Y]
set fnl_mm [clock format $datafnl -format %m]
set fnl_dd [clock format $datafnl -format %d]
set fnl_hh [clock format $datafnl -format %H]
set week_fnl3 $fnl_aaaa$fnl_mm$fnl_dd
set datafnl [expr [clock scan $saaaa$smm$sdd]+($shh*3600)-(24*3600*0)]
set fnl_aaaa [clock format $datafnl -format %Y]
set fnl_mm [clock format $datafnl -format %m]
set fnl_dd [clock format $datafnl -format %d]
set fnl_hh [clock format $datafnl -format %H]
set week_fnl4 $fnl_aaaa$fnl_mm$fnl_dd

#tracer
set dataf_tracer [expr [clock scan $wrf_aaaa$wrf_mm$wrf_dd]+[expr $shh*3600]+[expr $timestep_tracer*3600]]
set eaaaa_tracer [clock format $dataf_tracer -format %Y]
set emm_tracer [clock format $dataf_tracer -format %m]
set edd_tracer [clock format $dataf_tracer -format %d]
set ehh_tracer [clock format $dataf_tracer -format %H]


cd $HOME_DIR
cd $SCRIPT_DIR

#define procedure's log file
set flog [file join $HOME_DIR run_wrf_[clock format [clock seconds] -format "%Y-%m-%d_%H:%M:%S" ]\.log]
set log [open $flog w+]

#create output directory
  set WRF_TRACER_OUT_week [file join $WRF_TRACER_OUT $week]
  if { ![file exists $WRF_TRACER_OUT_week]} {file mkdir $WRF_TRACER_OUT_week; file attributes $WRF_TRACER_OUT_week -permissions a+rx;  puts $log "directory $WRF_TRACER_OUT_week made"}
  set WRF_NOFIRE_OUT_week [file join $WRF_NOFIRE_OUT $week]
  if { ![file exists $WRF_NOFIRE_OUT_week]} {file mkdir $WRF_NOFIRE_OUT_week; file attributes $WRF_NOFIRE_OUT_week -permissions a+rx;  puts $log "directory $WRF_NOFIRE_OUT_week made"}
  set WRF_ANALYSIS_OUT_week [file join $WRF_ANALYSIS_OUT $week]
  if { ![file exists $WRF_ANALYSIS_OUT_week]} {file mkdir $WRF_ANALYSIS_OUT_week; file attributes $WRF_ANALYSIS_OUT_week -permissions a+rx;  puts $log "directory $WRF_ANALYSIS_OUT_week made"}


if { $copy_delete == "yes" } {
  puts $log "# ---------------------------------------------------------"
  puts $log "# Copy restart files to a safe place"
  puts $log "# Delete previous wrfout files"
  puts $log "# ---------------------------------------------------------"
  flush $log

#### Edited by Pallavi 17 Aug 2010 to copy wrfrst files to safe place ##############
#cd $WRF_TRACER_DIR
#set rst_f [glob -nocomplain [file join $WRF_TRACER_DIR wrfrst_d0*]]
# foreach x $rst_f {
#  exec mv $x $WRF_TRACER_OUT/$week
#}
#puts " Finished writing restart files to safe place"
 #######to copy wrf out to safe place ###########
cd $WRF_TRACER_DIR
# if {[llength [glob -nocomplain  wrfout_d0*_$saaaa\-$smm\-$sdd\_$shh\:00:00]] > 0} {eval "file delete -force [glob -nocomplain  wrfout_d0*_$saaaa\-$smm\-$sdd\_$shh\:00:00]"}
if {[llength [glob -nocomplain  wrfout_d0*]] > 0} {eval "file delete -force [glob -nocomplain  wrfout_d0*]"}
 set wrf_o [glob -nocomplain [file join $WRF_TRACER_DIR wrfout_d0*]]
  foreach x $wrf_o {
  #exec mkdir $WRF_TRACER_OUT/$week/$week_wrf
  exec mv $x $WRF_TRACER_OUT/$week
}

}
#set HOME_DIR [file nativename [file dirname [info script]]]
cd $HOME_DIR
cd $SCRIPT_DIR



if { $fnl == "yes" } {
puts $log "# ---------------------------------------------------------"
puts $log "# get FNL forecat fields grib version 2 format"
puts $log "# from ftp.ncep.noaa.gov FTP ncep distribution site"
puts $log "# ---------------------------------------------------------"

  cd $SCRIPT_DIR
#  set c [catch { eval "exec $SCRIPT_DIR/download_fnl.sh ${week_fnl1}${shh} ${timestep_fnl} 3 ${fnl_dir}" } msg ]
  set c [catch { eval "exec ssh localhost \"bash $SCRIPT_DIR/download_fnl.sh ${week_fnl1}${shh} ${timestep_fnl} 3 ${fnl_dir} ${SCRIPT_DIR}\"" } msg ]
  puts $log $msg
  flush $log

}

if { $fnl_nitro == "yes" } {
puts $log "# ---------------------------------------------------------"
puts $log "# get FNL forecat fields grib version 2 format"
puts $log "# from ftp.ncep.noaa.gov FTP ncep distribution site"
puts $log "# ---------------------------------------------------------"

  cd $SCRIPT_DIR
  set c [catch { eval "exec ssh localhost \"bash $SCRIPT_DIR/download_fnl_nitrogen.sh ${week_fnl1}${shh} ${timestep_fnl} 3 ${fnl_dir} ${SCRIPT_DIR}\"" } msg ]
  puts $log $msg
  flush $log

}

if { $gfs_nitro == "yes" } {
puts $log "# ---------------------------------------------------------"
puts $log "# get GFS forecat fields grib version 2 format"
puts $log "# from ftp.ncep.noaa.gov FTP ncep distribution site"
puts $log "# ---------------------------------------------------------"

  cd $SCRIPT_DIR
  set c [catch { eval "exec ssh localhost \"bash $SCRIPT_DIR/download_gfs_nitrogen.sh ${week}${gfs_run} ${timestep_gfs} 3 ${gfs_dir} ${SCRIPT_DIR}\"" } msg ]
  puts $log $msg
  flush $log

}

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
  set remdir pub/data/nccf/com/gfs/prod/gfs.${week}${gfs_run}


  # ---------------------------------------------------------
  # check destination folder
  # ---------------------------------------------------------

  set METEO_INP [file join $gfs_dir $week\_$gfs_run]
  if { ![file exists $METEO_INP]} {file mkdir $METEO_INP; file attributes $METEO_INP -permissions a+rx;  puts $log "directory $METEO_INP made"}

  # ---------------------------------------------------------
  # dowload files
  # ---------------------------------------------------------

  set fore_step [expr $timestep_gfs+3]
  puts $log "fore_step $fore_step"

  for {set i 0} {$i <= $fore_step} {incr i 3} {
     # METEO file name
#     set F_INP  fh.[format "%04u" $i]\_tl.press_gr.1p00deg
#     set F_INP  fh.[format "%04u" $i]\_tl.press_gr.0p50deg
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

 #############################tO CHECK GFS DATA IS DOWNLOADED OR NOT######
#  cd $gfs_dir
#  while {![file exists $week\_$gfs_run ]} {
#  puts "$week\_$gfs_run not found ............ waiting for 2 min before checking again"
#  after 300000
#  }
#  puts "$week\_$gfs_run found"
##########


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
  if {[llength [glob -nocomplain [file join met_em.d*]]] > 0} {eval "file delete -force [glob -nocomplain [file join met_em.d*]]"}

  cd grib_files
  if {[llength [glob -nocomplain [file join gfs*]]] > 0} {eval "file delete -force [glob -nocomplain [file join gfs*]]"}
  if {[llength [glob -nocomplain [file join gdas*]]] > 0} {eval "file delete -force [glob -nocomplain [file join gdas*]]"}
  cd ../

  #met cycle
 
  #link GFS
  set gfs_f [glob -nocomplain [file join $gfs_dir $week\_$gfs_run gfs.*]]
  foreach x $gfs_f {
      exec ln -sf $x $WPS_DIR/grib_files/
  }
  #link FNL
  set gdas_f [glob -nocomplain [file join $fnl_dir gdas*$week_fnl1*]]
  foreach x $gdas_f { exec ln -sf $x $WPS_DIR/grib_files/ }
  set gdas_f [glob -nocomplain [file join $fnl_dir gdas*$week_fnl2*]]
  foreach x $gdas_f { exec ln -sf $x $WPS_DIR/grib_files/ }
  set gdas_f [glob -nocomplain [file join $fnl_dir gdas*$week_fnl3*]]
  foreach x $gdas_f { exec ln -sf $x $WPS_DIR/grib_files/ }
  set gdas_f [glob -nocomplain [file join $fnl_dir gdas*$week_fnl4*]]
  foreach x $gdas_f { exec ln -sf $x $WPS_DIR/grib_files/ }

#  set c [catch { eval "exec ./link_grib.csh [file join $gfs_dir $week\_$gfs_run gfs.0\*]" } msg ]
  set c [catch { eval "exec ./link_grib.csh [file join grib_files \*]" } msg ]
#  if {$c == 1 && $msg != 0} {puts $log "[clock format [clock seconds] -format "%H:%M:%S" ] |E| Standard Error link_grib.csh:\n$msg"; END_shell 1}

  set sedcommand [open sedcommand.sed w+]
  puts $sedcommand "s,_START_,$wrf_aaaa\-$wrf_mm\-$wrf_dd\_$wrf_hh:00:00,g"
  puts $sedcommand "s,_END_,$eaaaa\-$emm\-$edd\_$ehh\:00:00,g"
  close $sedcommand
  exec sed -f sedcommand.sed namelist.wps_met.sed  > namelist.wps
  file delete -force sedcommand.sed

#  exec ln -sf ungrib/Variable_Tables/Vtable.GFS_new Vtable

  set c [catch { eval "exec $WPS_DIR/ungrib.exe >& $WPS_DIR/ungrib_log" } msg ]
  set c [catch { eval "exec $SCRIPT_DIR/script_qsub.sh \"run_mod_levs_qsub.sh\" >& $WPS_DIR/script_qsub.sh.mod_levs_log" } msg ]
  set c [catch { eval "exec $SCRIPT_DIR/script_qsub.sh \"runmetgrid.csh\" >& $WPS_DIR/script_qsub.sh.metgrid_log" } msg ]

  puts $log $msg
 
  cd $HOME_DIR
}



cd $HOME_DIR
set FIRE_OUT_week [file join $fire_qfed2_dir $week]
set FIRE_TRACER_OUT_week [file join $fire_qfed2_dir $week with_tracer68]
set FIRE_ANA_OUT_week [file join $fire_qfed2_dir $week constrained]
set FIRE_ANA_TRACER_OUT_week [file join $fire_qfed2_dir $week constrained with_tracer16]

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

  cd $FIRE_DIR

  puts $log "$fire_aaaa$fire_mm$fire_dd$fire_hh $eaaaa$emm$edd$ehh"
  flush $log
  #do some cleaning
  if {[llength [glob -nocomplain wrffirechemi_d*]] > 0} {eval "file delete -force [glob -nocomplain wrffirechemi_d*]"}

  # Download fire emission files. NOTE: Only downloading until current day
  puts $log "# Download fire emission files"
  puts $log "exec ssh localhost \"bash $FIRE_SCRIPT_DIR/download_qfed2_saprc99_emiss.sh $FIRE_SCRIPT_DIR $fire_aaaa$fire_mm$fire_dd$fire_hh $saaaa$smm$sdd$gfs_run >& $FIRE_SCRIPT_DIR/download_qfed2_log\""
  flush $log
  cd $FIRE_SCRIPT_DIR
  set c [catch { eval "exec ssh localhost \"bash $FIRE_SCRIPT_DIR/download_qfed2_saprc99_emiss.sh $FIRE_SCRIPT_DIR $fire_aaaa$fire_mm$fire_dd$fire_hh $saaaa$smm$sdd$gfs_run >& $FIRE_SCRIPT_DIR/download_qfed2_log\"" } msg ]
  puts $log $msg
  flush $log

  # Concatenate and fill fire emissions
  puts $log "# Concatenate and fill fire emissions "
  flush $log
  cd $FIRE_SCRIPT_DIR
  puts $log "exec $qsub_1proc_cmd /usr/bin/ssh localhost \"${FIRE_SCRIPT_DIR}/preprosses_qfed2_saprc99_emiss_qsub.sh $FIRE_SCRIPT_DIR $fire_aaaa$fire_mm$fire_dd$fire_hh $eaaaa$emm$edd$ehh\" >& $FIRE_SCRIPT_DIR/script_qsub.sh.preprosses_qfed2_log"
  flush $log
  set c [catch { eval "exec $qsub_1proc_cmd /usr/bin/ssh localhost \"${FIRE_SCRIPT_DIR}/preprosses_qfed2_saprc99_emiss_qsub.sh $FIRE_SCRIPT_DIR $fire_aaaa$fire_mm$fire_dd$fire_hh $eaaaa$emm$edd$ehh\" >& $FIRE_SCRIPT_DIR/script_qsub.sh.preprosses_qfed2_log" } msg ]
  puts $log $msg
  flush $log

#  puts $log "# FORCING END OF SCRIPT"
#  flush $log
#  exit

  cd $FIRE_DIR

  # bring files to cluster
  puts $log $msg
  puts $log "# Bring fire files to cluster "
  flush $log
  set c [catch {eval "exec  mv $FIRE_QFED2_FILE_DIR\/QFED_in_FINN_format_REDHC_pm10_$fire_aaaa$fire_mm$fire_dd$fire_hh\_$eaaaa$emm$edd$ehh\.txt $fire_qfed2_dir" } msg ]

  # modify namelist
  set sedcommand [open sedcommand.sed w+]
  puts $sedcommand "s,_START_,$fire_aaaa$fire_mm$fire_dd$fire_hh,g"
  puts $sedcommand "s,_END_,$eaaaa$emm$edd$ehh,g"
  puts $sedcommand "s,_START2_,$fire_aaaa\-$fire_mm\-$fire_dd,g"
  puts $sedcommand "s,_END2_,$eaaaa\-$emm\-$edd,g"
  puts $sedcommand "s,_WRF_DIR_,$FIRE_DIR,g"
  puts $sedcommand "s,_fire_dir_,$fire_qfed2_dir,g"
  close $sedcommand
#  exec sed -f sedcommand.sed fire_emis.saprc99.inp_ORACLES_qfed_scaledBC_pm10.sed  > fire_emis.mozc.inp
  exec sed -f sedcommand.sed fire_emis.redhc.ORACLES_qfed_scaleBC_pm10.sed  > fire_emis.mozc.inp
  file delete -force sedcommand.sed

  # run fire_emiss
  puts $log "# Run fire_emiss "
  set c [catch {eval "exec rm $FIRE_DIR/wrfinput_d01" } msg ]
  set c [catch {eval "exec ln -s $WRF_TRACER_DIR/wrfinput_d01 $FIRE_DIR/wrfinput_d01" } msg ]
  set c [catch { eval "exec $SCRIPT_DIR/script_qsub.sh \"run_fire_emis_qsub.sh\" >& $FIRE_DIR/script_qsub.sh.fire_emis_log" } msg ]
  puts $log $msg

  # clean WRF dir
  cd $WRF_TRACER_DIR
  if {[llength [glob -nocomplain wrffirechemi_d*]] > 0} {eval "file delete -force [glob -nocomplain wrffirechemi_d*]"}
  cd $FIRE_DIR

  # move files to fire folder
  puts $log "# move files to fire_qfed2 folder "
  set fire_f [glob -nocomplain [file join $FIRE_DIR wrffirechemi_d*]]
   foreach x $fire_f {
    exec mv $x $FIRE_OUT_week/
  }
  puts "Moved wrffirechemi_D01 to FIRE folder"

  # copy files so model wont crash if inversion is not suscessfull
#  puts $log "#  copy files to constrained folder "
#  set fire_f [glob -nocomplain [file join $FIRE_OUT_week wrffirechemi_d*]]
#   foreach x $fire_f {
#    exec cp $x $FIRE_ANA_OUT_week/
#  }
#  puts "Copied wrffirechemi_D01 to CONSTRAINED folder"

  # Add tracers
  # copy base file
  set c [catch {eval "exec cp $fire_qfed2_dir/wrffirechemi_d01_tracer68_base $FIRE_TRACER_OUT_week/wrffirechemi_d01_tracer_base" } msg ] 
  set c [catch {eval "exec cp $fire_qfed2_dir/wrffirechemi_d01_tracer16_base $FIRE_ANA_TRACER_OUT_week/wrffirechemi_d01_tracer_base" } msg ]

  # create tracers
  cd ${MATLAB_TRACER_DIR}
  puts $log "exec $qsub_1proc_cmd /usr/bin/ssh localhost \"${MATLAB_TRACER_DIR}/run_create_tracer_emissions_68tr_fn.sh $wrf_aaaa $wrf_mm $wrf_dd $wrf_hh $eaaaa_tracer $emm_tracer $edd_tracer $ehh_tracer $wrf_aaaa $wrf_mm $wrf_dd $wrf_hh $eaaaa_tracer $emm_tracer $edd_tracer $ehh_tracer 68 ${FIRE_OUT_week} ${FIRE_TRACER_OUT_week} ${anthro_emis_dir} ${WRF_TRACER_DIR} ${MATLAB_TRACER_DIR}\" >& $MATLAB_TRACER_DIR/script_qsub.sh.create_tracer_emissions_log"
  flush $log
  set c [catch { eval "exec $qsub_1proc_cmd /usr/bin/ssh localhost \"${MATLAB_TRACER_DIR}/run_create_tracer_emissions_68tr_fn.sh $wrf_aaaa $wrf_mm $wrf_dd $wrf_hh $eaaaa_tracer $emm_tracer $edd_tracer $ehh_tracer $wrf_aaaa $wrf_mm $wrf_dd $wrf_hh $eaaaa_tracer $emm_tracer $edd_tracer $ehh_tracer 68 ${FIRE_OUT_week} ${FIRE_TRACER_OUT_week} ${anthro_emis_dir} ${WRF_TRACER_DIR} ${MATLAB_TRACER_DIR}\" >& $MATLAB_TRACER_DIR/script_qsub.sh.create_tracer_emissions_log" } msg ]
  puts $log $msg
  flush $log

  # Link fire files to WRF directory
  set fire_f [glob -nocomplain [file join $FIRE_TRACER_OUT_week wrffirechemi_d*]]
   foreach x $fire_f {
    exec ln -s $x $WRF_TRACER_DIR/
  }
  puts "Linked wrffirechemi_D01 to WRF folder"

}



if { $fire == "yes" } {
puts $log "# ---------------------------------------------------------"
puts $log "# run preprosses_finn_emiss.m "
puts $log "# run fire_emis"
puts $log "# ---------------------------------------------------------"
flush $log

  cd $FIRE_DIR

  puts $log "$fire_aaaa$fire_mm$fire_dd$fire_hh $eaaaa$emm$edd$ehh"
  flush $log
  #do some cleaning
  if {[llength [glob -nocomplain wrffirechemi_d*]] > 0} {eval "file delete -force [glob -nocomplain wrffirechemi_d*]"}

  # Download, concatenate and fill fire emissions
  puts $log "# Download, concatenate and fill fire emissions "
  flush $log
# this doesn't outputs log but keeps running
   set c [catch {eval "exec ssh psaide@snow2.cgrer.uiowa.edu $FIRE_SCRIPT_DIR/preprosses_finn_saprc99_emiss.sh $FIRE_SCRIPT_DIR $fire_aaaa$fire_mm$fire_dd$fire_hh $eaaaa$emm$edd$ehh" } msg ]

  # bring files to cluster
  puts $log $msg
  puts $log "# Bring fire files to cluster "
  flush $log
  set c [catch {eval "exec scp psaide@snow2.cgrer.uiowa.edu:$FIRE_FILE_DIR\/GLOB_SAPRC99_$fire_aaaa$fire_mm$fire_dd$fire_hh\_$eaaaa$emm$edd$ehh\.txt psaide@helium.hpc.uiowa.edu:$fire_dir" } msg ]

  # modify namelist
  set sedcommand [open sedcommand.sed w+]
  puts $sedcommand "s,_START_,$fire_aaaa$fire_mm$fire_dd$fire_hh,g"
  puts $sedcommand "s,_END_,$eaaaa$emm$edd$ehh,g"
  puts $sedcommand "s,_START2_,$fire_aaaa\-$fire_mm\-$fire_dd,g"
  puts $sedcommand "s,_END2_,$eaaaa\-$emm\-$edd,g"
  puts $sedcommand "s,_WRF_TRACER_DIR_,$WRF_TRACER_DIR,g"
  puts $sedcommand "s,_fire_dir_,$fire_dir,g"
  close $sedcommand
  exec sed -f sedcommand.sed fire_emis.saprc99.inp_SEAC4RS_US.sed  > fire_emis.mozc.inp
  file delete -force sedcommand.sed

  # run fire_emiss
  puts $log "# Run fire_emiss "
  set c [catch {eval "exec ./fire_emis < fire_emis.mozc.inp > fire_emis.mozc.inp.log" } msg ]
  puts $log $msg

  # clean WRF dir
  cd $WRF_TRACER_DIR
#  if {[llength [glob -nocomplain wrffirechemi_d*]] > 0} {eval "file delete -force [glob -nocomplain wrffirechemi_d*]"}
  cd $FIRE_DIR

  # copy tracer information
  puts $log "#  copy tracer information "
#  set fire_f [glob -nocomplain [file join $FIRE_DIR wrffirechemi_d*]]
  set fire_f [glob -nocomplain [file join wrffirechemi_d*]]
   foreach x $fire_f {
#    puts $log "ncks -v ebu_in_co $x $x\_co"
    set c [catch {eval "exec ncks -v ebu_in_co $x $x\_co" } msg ]
    puts $log $msg
#    puts $log "ncrename -v ebu_in_co,ebu_in_co_1 $x\_co"
    set c [catch {eval "exec ncrename -v ebu_in_co,ebu_in_co_1 $x\_co" } msg ]
    puts $log $msg
#    puts $log "ncks -A -v ebu_in_co_1 $x\_co $WRF_TRACER_DIR\/$x"
    set c [catch {eval "exec ncks -A -v ebu_in_co_1 $x\_co $WRF_TRACER_DIR\/$x" } msg ]
    puts $log $msg
  }
  puts "COpyed wrffirechemi files to WRF folder"
}






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
  exec sed -f sedcommand.sed namelist.input_real.sed  > namelist.input
  file delete -force sedcommand.sed

  #link met files
  set met_f [glob -nocomplain [file join $WPS_DIR met_em.d*]]
  foreach x $met_f {
        exec ln -sf $x .
        }

  # link first wrffire file for real.exe
  set c [catch {eval "exec ln -sf wrffirechemi_d01_$wrf_aaaa\-$wrf_mm\-$wrf_dd\_$wrf_hh\:00:00 wrffirechemi_d01" } msg ]  

  # Submitt
  set c [catch { eval "exec $SCRIPT_DIR/script_qsub.sh \"runreal.csh\" >& $WRF_TRACER_DIR/script_qsub.sh.real_log" } msg ]
  puts $log $msg
##############check wrfinput-files are generated to proceed further###########
 cd $WRF_TRACER_DIR
  while {![file exists wrfinput_d01]} {
  puts "inputfile not found ............ waiting for 2 min before checking again"
  after 300000
  }
  puts "input file found"

}


if { $macc == "yes" } {
puts $log "# ---------------------------------------------------------"
puts $log "# Download MACC and run mozbc"
puts $log "# ---------------------------------------------------------"
flush $log

#############Download MACC########
cd $macc_dir
set sedcommand [open sedcommand.sed w+]
 puts $sedcommand "s,_START_,$rst_aaaa$rst_mm$rst_dd,g"
  close $sedcommand

  exec sed -f sedcommand.sed download_macc_psaide.sh.sed  > download.sh
  file delete -force sedcommand.sed
  set c [catch {eval "exec chmod +x download.sh"} msg ]

  set c [catch {eval "exec ./download.sh"} msg ]
  puts $log $msg
  puts "download complete same day"
############download previos day######
#  puts "downloding previous day file again"
#  set sedcommand [open sedcommand.sed w+]
#  puts $sedcommand "s,_START_,$mac_aaaa$mac_mm$mac_dd,g"
#  close $sedcommand
#
#  exec sed -f sedcommand.sed download_macc_psaide.sh.sed  > download.sh
#  file delete -force sedcommand.sed
#  set c [catch {eval "exec chmod +x download.sh"} msg ]
#  set c [catch {eval "exec ./download.sh"} msg ]
#  puts $log $msg
#  puts "download complete"
#### Edited by Pallavi 17 Aug 2010 to add boundary and replace wrfinput files to run wrfchem ##############
########## Add boundary conditions subroutine
cd $MOZ_DIR
if { [file exists $macc_dir/MACC_$rst_aaaa$rst_mm$rst_dd.nc]} {

# join with older file
 set c [catch { eval "exec $MOZ_DIR/join_macc_files.sh $rst_aaaa$rst_mm$rst_dd $wrf_aaaa$wrf_mm$wrf_dd 15 $macc_dir" } msg ]
 puts $log $msg
 flush $log

set sedcommand [open sedcommand.sed w+]
 puts $sedcommand "s,_START_,$rst_aaaa$rst_mm$rst_dd,g"
 puts $sedcommand "s,_macc_dir_,$macc_dir,g"
 close $sedcommand

  exec sed -f sedcommand.sed gthompson_oracles.inp.sed  > gthompson_oracles.inp
  file delete -force sedcommand.sed
#  set c [catch { eval "exec $MOZ_DIR/run_mozbc.sh" } msg ]
  set c [catch { eval "exec $SCRIPT_DIR/script_qsub.sh \"runmozbc.csh\" >& $MOZ_DIR/script_qsub.sh.mozbc_log" } msg ]
  puts $log $msg
 puts "used same day boundary conditions"
} else {
 if { [file exists $macc_dir/MACC_$mac_aaaa$mac_mm$mac_dd.nc]} {
  puts "using previous day"

  # join with older file
  set c [catch { eval "exec $MOZ_DIR/join_macc_files.sh $mac_aaaa$mac_mm$mac_dd $wrf_aaaa$wrf_mm$wrf_dd 7 $macc_dir" } msg ]
  puts $log $msg
  flush $log

  set sedcommand [open sedcommand.sed w+]
  puts $sedcommand "s,_START_,$mac_aaaa$mac_mm$mac_dd,g"
  puts $sedcommand "s,_macc_dir_,$macc_dir,g"
  close $sedcommand

  exec sed -f sedcommand.sed gthompson_oracles.inp.sed  > gthompson_oracles.inp
  file delete -force sedcommand.sed
#  set c [catch { eval "exec $MOZ_DIR/run_mozbc.sh" } msg ]
  set c [catch { eval "exec $SCRIPT_DIR/script_qsub.sh \"runmozbc.csh\" >& $MOZ_DIR/script_qsub.sh.mozbc_log" } msg ]
  puts $log $msg
  puts "used previous day boundary conditions"
 }
}

}

if { $rst_ic == "yes" } {
puts $log "# ---------------------------------------------------------"
puts $log "# Copy data from previous run"
puts $log "# ---------------------------------------------------------"
flush $log

# Copy wrfinput and wrf_bdy to all runs
set c [catch {eval "exec cp $WRF_TRACER_DIR/wrfinput_d01 $WRF_NOFIRE_DIR/" } msg ]
set c [catch {eval "exec cp $WRF_TRACER_DIR/wrfbdy_d01 $WRF_NOFIRE_DIR/" } msg ]
set c [catch {eval "exec cp $WRF_TRACER_DIR/wrffdda_d01 $WRF_NOFIRE_DIR/" } msg ]
set c [catch {eval "exec cp $WRF_TRACER_DIR/wrfinput_d01 $WRF_ANALYSIS_DIR/" } msg ]
set c [catch {eval "exec cp $WRF_TRACER_DIR/wrfbdy_d01 $WRF_ANALYSIS_DIR/" } msg ]
set c [catch {eval "exec cp $WRF_TRACER_DIR/wrffdda_d01 $WRF_ANALYSIS_DIR/" } msg ]

set wrfrst_file1 [file join $WRF_ANALYSIS_OUT $week_rst wrfout_d01_$wrf_aaaa\-$wrf_mm\-$wrf_dd\_$wrf_hh\:00:00]
set wrfinput_file1 [file join $WRF_TRACER_DIR wrfinput_d01]
cd $WRF_TRACER_DIR
if { [file exists $wrfrst_file1]} {
     puts "Restart file found"
#     set c [catch { eval "exec $WRF_TRACER_DIR/copy_restart_to_input.sh $wrfrst_file1" } msg ]
     set c [catch { eval "exec $qsub_1proc_cmd /usr/bin/ssh localhost \"${MATLAB_TRACER_DIR}/restart_tracers_68tr.sh ${wrfrst_file1} ${wrfinput_file1} ${MATLAB_TRACER_DIR}\" >& $MATLAB_TRACER_DIR/script_qsub.sh.restart_tracers_68tr_log" } msg ]
     puts $log $msg
     flush $log
} else {
     puts "Restart file not found, skipping 1 cycle"

     set wrfrst_file1 [file join $WRF_ANALYSIS_OUT $week_rst_skip1 wrfout_d01_$wrf_aaaa\-$wrf_mm\-$wrf_dd\_$wrf_hh\:00:00]
     cd $WRF_TRACER_DIR
     if { [file exists $wrfrst_file1]} {
          puts $log "Restart file found"
          set c [catch { eval "exec $qsub_1proc_cmd /usr/bin/ssh localhost \"${MATLAB_TRACER_DIR}/restart_tracers_68tr_skip1.sh ${wrfrst_file1} ${wrfinput_file1} ${MATLAB_TRACER_DIR}\" >& $MATLAB_TRACER_DIR/script_qsub.sh.restart_tracers_68tr_log" } msg ]
          puts $log $msg
          flush $log
     } else {
          puts $log "Restart file not found, skipping 2 cycles"

          set wrfrst_file1 [file join $WRF_ANALYSIS_OUT $week_rst_skip2 wrfout_d01_$wrf_aaaa\-$wrf_mm\-$wrf_dd\_$wrf_hh\:00:00]
          cd $WRF_TRACER_DIR
          if { [file exists $wrfrst_file1]} {
               puts $log "Restart file found"
               set c [catch { eval "exec $qsub_1proc_cmd /usr/bin/ssh localhost \"${MATLAB_TRACER_DIR}/restart_tracers_68tr_skip2.sh ${wrfrst_file1} ${wrfinput_file1} ${MATLAB_TRACER_DIR}\" >& $MATLAB_TRACER_DIR/script_qsub.sh.restart_tracers_68tr_log" } msg ]
               puts $log $msg
               flush $log
          } else {
               puts $log "Restart file not found, skipping 3 cycles"

               set wrfrst_file1 [file join $WRF_ANALYSIS_OUT $week_rst_skip3 wrfout_d01_$wrf_aaaa\-$wrf_mm\-$wrf_dd\_$wrf_hh\:00:00]
               cd $WRF_TRACER_DIR
               if { [file exists $wrfrst_file1]} {
                    puts $log "Restart file found"
#                    puts $log "exec $qsub_1proc_cmd /usr/bin/ssh localhost \"${MATLAB_TRACER_DIR}/restart_tracers_68tr_skip3.sh ${wrfrst_file1} ${wrfinput_file1} ${MATLAB_TRACER_DIR}\" >& $MATLAB_TRACER_DIR/script_qsub.sh.restart_tracers_68tr_log"
                    set c [catch { eval "exec $qsub_1proc_cmd /usr/bin/ssh localhost \"${MATLAB_TRACER_DIR}/restart_tracers_68tr_skip3.sh ${wrfrst_file1} ${wrfinput_file1} ${MATLAB_TRACER_DIR}\" >& $MATLAB_TRACER_DIR/script_qsub.sh.restart_tracers_68tr_log" } msg ]
                    puts $log $msg
                    flush $log
               } else {
                    puts $log "Restart file not found, skipping 4 cycles"

                    set wrfrst_file1 [file join $WRF_ANALYSIS_OUT $week_rst_skip4 wrfout_d01_$wrf_aaaa\-$wrf_mm\-$wrf_dd\_$wrf_hh\:00:00]
                    cd $WRF_TRACER_DIR
                    if { [file exists $wrfrst_file1]} {
                         puts "Restart file found"
                         set c [catch { eval "exec $qsub_1proc_cmd /usr/bin/ssh localhost \"${MATLAB_TRACER_DIR}/restart_tracers_68tr_skip4.sh ${wrfrst_file1} ${wrfinput_file1} ${MATLAB_TRACER_DIR}\" >& $MATLAB_TRACER_DIR/script_qsub.sh.restart_tracers_68tr_log" } msg ]
                         puts $log $msg
                         flush $log
                    } else {
                         puts $log "Restart file not found, NOT ADDING INITIAL CONDITIONS"

                    }
               }
          }
     }
}

set wrfrst_file1 [file join $WRF_ANALYSIS_OUT $week_rst wrfout_d01_$wrf_aaaa\-$wrf_mm\-$wrf_dd\_$wrf_hh\:00:00]
set wrfinput_file1 [file join $WRF_ANALYSIS_DIR wrfinput_d01]
cd $WRF_ANALYSIS_DIR
if { [file exists $wrfrst_file1]} {
     puts $log "Restart file found"
#     set c [catch { eval "exec $WRF_ANALYSIS_DIR/copy_restart_to_input.sh $wrfrst_file1" } msg ]
     set c [catch { eval "exec $qsub_1proc_cmd /usr/bin/ssh localhost \"${MATLAB_TRACER_DIR}/restart_tracers_16tr.sh ${wrfrst_file1} ${wrfinput_file1} ${MATLAB_TRACER_DIR}\" >& $MATLAB_TRACER_DIR/script_qsub.sh.restart_tracers_16tr_log" } msg ]
     puts $log $msg
     flush $log
} else {
     puts $log "Restart file not found, skipping 1 cycle"

     set wrfrst_file1 [file join $WRF_ANALYSIS_OUT $week_rst_skip1 wrfout_d01_$wrf_aaaa\-$wrf_mm\-$wrf_dd\_$wrf_hh\:00:00]
     cd $WRF_ANALYSIS_DIR
     if { [file exists $wrfrst_file1]} {
          puts $log "Restart file found"
          set c [catch { eval "exec $qsub_1proc_cmd /usr/bin/ssh localhost \"${MATLAB_TRACER_DIR}/restart_tracers_16tr_skip1.sh ${wrfrst_file1} ${wrfinput_file1} ${MATLAB_TRACER_DIR}\" >& $MATLAB_TRACER_DIR/script_qsub.sh.restart_tracers_16tr_log" } msg ]
          puts $log $msg
          flush $log
     } else {
          puts $log "Restart file not found, skipping 2 cycles"

          set wrfrst_file1 [file join $WRF_ANALYSIS_OUT $week_rst_skip2 wrfout_d01_$wrf_aaaa\-$wrf_mm\-$wrf_dd\_$wrf_hh\:00:00]
          cd $WRF_ANALYSIS_DIR
          if { [file exists $wrfrst_file1]} {
               puts $log "Restart file found"
               set c [catch { eval "exec $qsub_1proc_cmd /usr/bin/ssh localhost \"${MATLAB_TRACER_DIR}/restart_tracers_16tr_skip2.sh ${wrfrst_file1} ${wrfinput_file1} ${MATLAB_TRACER_DIR}\" >& $MATLAB_TRACER_DIR/script_qsub.sh.restart_tracers_16tr_log" } msg ]
               puts $log $msg
               flush $log
          } else {
               puts $log "Restart file not found, skipping 3 cycles"

               set wrfrst_file1 [file join $WRF_ANALYSIS_OUT $week_rst_skip3 wrfout_d01_$wrf_aaaa\-$wrf_mm\-$wrf_dd\_$wrf_hh\:00:00]
               cd $WRF_ANALYSIS_DIR
               if { [file exists $wrfrst_file1]} {
                    puts $log "Restart file found"
                    set c [catch { eval "exec $qsub_1proc_cmd /usr/bin/ssh localhost \"${MATLAB_TRACER_DIR}/restart_tracers_16tr_skip3.sh ${wrfrst_file1} ${wrfinput_file1} ${MATLAB_TRACER_DIR}\" >& $MATLAB_TRACER_DIR/script_qsub.sh.restart_tracers_16tr_log" } msg ]
                    puts $log $msg
                    flush $log
               } else {
                    puts $log "Restart file not found, skipping 4 cycles"

                    set wrfrst_file1 [file join $WRF_ANALYSIS_OUT $week_rst_skip4 wrfout_d01_$wrf_aaaa\-$wrf_mm\-$wrf_dd\_$wrf_hh\:00:00]
                    cd $WRF_ANALYSIS_DIR
                    if { [file exists $wrfrst_file1]} {
                         puts $log "Restart file found"
                         set c [catch { eval "exec $qsub_1proc_cmd /usr/bin/ssh localhost \"${MATLAB_TRACER_DIR}/restart_tracers_16tr_skip4.sh ${wrfrst_file1} ${wrfinput_file1} ${MATLAB_TRACER_DIR}\" >& $MATLAB_TRACER_DIR/script_qsub.sh.restart_tracers_16tr_log" } msg ]
                         puts $log $msg
                         flush $log
                    } else {
                         puts $log "Restart file not found, NOT ADDING INITIAL CONDITIONS"

                    }
               }
          }
     }
}

set wrfrst_file1 [file join $WRF_NOFIRE_OUT $week_rst wrfout_d01_$wrf_aaaa\-$wrf_mm\-$wrf_dd\_$wrf_hh\:00:00]
set wrfinput_file1 [file join $WRF_NOFIRE_DIR wrfinput_d01]
cd $WRF_NOFIRE_DIR
if { [file exists $wrfrst_file1]} {
     puts $log "Restart file found"
#     set c [catch { eval "exec $WRF_NOFIRE_DIR/copy_restart_to_input.sh $wrfrst_file1" } msg ]
     set c [catch { eval "exec $qsub_1proc_cmd /usr/bin/ssh localhost \"${MATLAB_TRACER_DIR}/restart_tracers_nofire.sh ${wrfrst_file1} ${wrfinput_file1} ${MATLAB_TRACER_DIR}\" >& $MATLAB_TRACER_DIR/script_qsub.sh.restart_tracers_nofire_log" } msg ]
     puts $log $msg
     flush $log
} else {
     puts $log "Restart file not found, skipping 1 cycle"

     set wrfrst_file1 [file join $WRF_NOFIRE_OUT $week_rst_skip1 wrfout_d01_$wrf_aaaa\-$wrf_mm\-$wrf_dd\_$wrf_hh\:00:00]
     cd $WRF_NOFIRE_DIR
     if { [file exists $wrfrst_file1]} {
          puts $log "Restart file found"
          set c [catch { eval "exec $qsub_1proc_cmd /usr/bin/ssh localhost \"${MATLAB_TRACER_DIR}/restart_tracers_nofire.sh ${wrfrst_file1} ${wrfinput_file1} ${MATLAB_TRACER_DIR}\" >& $MATLAB_TRACER_DIR/script_qsub.sh.restart_tracers_nofire_log" } msg ]
          puts $log $msg
          flush $log
     } else {
          puts $log "Restart file not found, skipping 2 cycles"

          set wrfrst_file1 [file join $WRF_NOFIRE_OUT $week_rst_skip2 wrfout_d01_$wrf_aaaa\-$wrf_mm\-$wrf_dd\_$wrf_hh\:00:00]
          cd $WRF_NOFIRE_DIR
          if { [file exists $wrfrst_file1]} {
               puts $log "Restart file found"
               set c [catch { eval "exec $qsub_1proc_cmd /usr/bin/ssh localhost \"${MATLAB_TRACER_DIR}/restart_tracers_nofire.sh ${wrfrst_file1} ${wrfinput_file1} ${MATLAB_TRACER_DIR}\" >& $MATLAB_TRACER_DIR/script_qsub.sh.restart_tracers_nofire_log" } msg ]
               puts $log $msg
               flush $log
          } else {
               puts $log "Restart file not found, skipping 3 cycles"

               set wrfrst_file1 [file join $WRF_NOFIRE_OUT $week_rst_skip3 wrfout_d01_$wrf_aaaa\-$wrf_mm\-$wrf_dd\_$wrf_hh\:00:00]
               cd $WRF_NOFIRE_DIR
               if { [file exists $wrfrst_file1]} {
                    puts $log "Restart file found"
                    set c [catch { eval "exec $qsub_1proc_cmd /usr/bin/ssh localhost \"${MATLAB_TRACER_DIR}/restart_tracers_nofire.sh ${wrfrst_file1} ${wrfinput_file1} ${MATLAB_TRACER_DIR}\" >& $MATLAB_TRACER_DIR/script_qsub.sh.restart_tracers_nofire_log" } msg ]
                    puts $log $msg
                    flush $log
               } else {
                    puts $log "Restart file not found, skipping 4 cycles"

                    set wrfrst_file1 [file join $WRF_NOFIRE_OUT $week_rst_skip4 wrfout_d01_$wrf_aaaa\-$wrf_mm\-$wrf_dd\_$wrf_hh\:00:00]
                    cd $WRF_NOFIRE_DIR
                    if { [file exists $wrfrst_file1]} {
                         puts $log "Restart file found"
                         set c [catch { eval "exec $qsub_1proc_cmd /usr/bin/ssh localhost \"${MATLAB_TRACER_DIR}/restart_tracers_nofire.sh ${wrfrst_file1} ${wrfinput_file1} ${MATLAB_TRACER_DIR}\" >& $MATLAB_TRACER_DIR/script_qsub.sh.restart_tracers_nofire_log" } msg ]
                         puts $log $msg
                         flush $log
                    } else {
                         puts $log "Restart file not found, NOT ADDING INITIAL CONDITIONS"

                    }
               }
          }
     }

 }

}



if { $wrf_part1 == "yes" } {
puts $log "# ---------------------------------------------------------"
puts $log "# run wrf part1"
puts $log "# ---------------------------------------------------------"
flush $log

  cd $SCRIPT_DIR

  set c [catch { eval "exec $SCRIPT_DIR/run_wrf_tracer_inversion_part1.sh $wrf_aaaa $wrf_mm $wrf_dd $wrf_hh $timestep_tracer $timestep_nofire $timestep $timestep_16tracer ${WRF_TRACER_DIR} ${WRF_NOFIRE_DIR} ${WRF_ANALYSIS_DIR} ${WRF_TRACER_OUT_week} ${WRF_NOFIRE_OUT_week} ${WRF_ANALYSIS_OUT_week} ${FIRE_OUT_week} ${FIRE_ANA_OUT_week} ${FIRE_ANA_TRACER_OUT_week} ${anthro_emis_dir} ${WRF_TRACER_DIR} ${SCRIPT_DIR} ${MATLAB_TRACER_DIR} ${NNR_STORE_DIR} ${NNR_SCRIPT} ${JOINER_DIR} 68 16" } msg ]
  puts $log $msg
  flush $log

  cd $SCRIPT_DIR
}

if { $wrf_part2 == "yes" } {
puts $log "# ---------------------------------------------------------"
puts $log "# run wrf part2"
puts $log "# ---------------------------------------------------------"
flush $log

  cd $SCRIPT_DIR

  set c [catch { eval "exec /usr/bin/ssh localhost \"$SCRIPT_DIR/run_wrf_tracer_inversion_part2.sh $wrf_aaaa $wrf_mm $wrf_dd $wrf_hh $timestep_tracer $timestep_nofire $timestep $timestep_16tracer ${WRF_TRACER_DIR} ${WRF_NOFIRE_DIR} ${WRF_ANALYSIS_DIR} ${WRF_TRACER_OUT_week} ${WRF_NOFIRE_OUT_week} ${WRF_ANALYSIS_OUT_week} ${FIRE_OUT_week} ${FIRE_ANA_OUT_week} ${FIRE_ANA_TRACER_OUT_week} ${anthro_emis_dir} ${WRF_TRACER_DIR} ${SCRIPT_DIR} ${MATLAB_TRACER_DIR} ${NNR_STORE_DIR} ${NNR_SCRIPT} ${JOINER_DIR} 68 16\"" } msg ]
  puts $log $msg
  flush $log

  cd $SCRIPT_DIR
}

if { $wrf_part3 == "yes" } {
puts $log "# ---------------------------------------------------------"
puts $log "# run wrf part3"
puts $log "# ---------------------------------------------------------"
flush $log

  cd $SCRIPT_DIR

  set c [catch { eval "exec $SCRIPT_DIR/run_wrf_tracer_inversion_part3.sh $wrf_aaaa $wrf_mm $wrf_dd $wrf_hh $timestep_tracer $timestep_nofire $timestep $timestep_16tracer ${WRF_TRACER_DIR} ${WRF_NOFIRE_DIR} ${WRF_ANALYSIS_DIR} ${WRF_TRACER_OUT_week} ${WRF_NOFIRE_OUT_week} ${WRF_ANALYSIS_OUT_week} ${FIRE_OUT_week} ${FIRE_ANA_OUT_week} ${FIRE_ANA_TRACER_OUT_week} ${anthro_emis_dir} ${WRF_TRACER_DIR} ${SCRIPT_DIR} ${MATLAB_TRACER_DIR} ${NNR_STORE_DIR} ${NNR_SCRIPT} ${JOINER_DIR} 68 16" } msg ]
  puts $log $msg
  flush $log

  cd $SCRIPT_DIR
}




if { $ncl_plot == "yes" } {
puts $log "# ---------------------------------------------------------"
puts $log "# Generate plots "
puts $log "# Copy plots to website"
puts $log "# ---------------------------------------------------------"
flush $log

  cd $WRF_TRACER_DIR
#create plot directory
  set NCL_PLOT_DIR [file join $WRF_ANALYSIS_OUT $week ncl_figs]
  if { ![file exists $NCL_PLOT_DIR]} {file mkdir $NCL_PLOT_DIR; file attributes $NCL_PLOT_DIR -permissions a+rx;  puts $log "directory $NCL_PLOT_DIR made"}
flush $log

# generate plots
  cd $NCL_SCRIPT_DIR
  set c [catch { eval "exec ./submit_run_all_count_loop1.sh $saaaa\-$smm\-$sdd\_$gfs_run\:00:00 $WRF_ANALYSIS_OUT_week $WRF_NOFIRE_OUT_week $NCL_PLOT_DIR 1 1 1 1 $NCL_SCRIPT_DIR" } msg ]
puts $log $msg
flush $log
# Check that or plots are there
  set c [catch { eval "exec ./submit_run_all_count_loop1_check.sh $saaaa\-$smm\-$sdd\_$gfs_run\:00:00 $WRF_ANALYSIS_OUT_week $WRF_NOFIRE_OUT_week $NCL_PLOT_DIR 1 1 1 1 $NCL_SCRIPT_DIR" } msg ]
puts $log $msg
flush $log

# create folder and copy files
  set NEW_CGRER_HTML_DIR [file join $CGRER_HTML_DIR wrf_aam_$saaaa-$smm-$sdd]
  set c [catch {eval "exec ssh saide@nitrogen.acom.ucar.edu mkdir $NEW_CGRER_HTML_DIR" } msg ]
puts $log $msg
flush $log
  set c [catch { eval "exec $NCL_SCRIPT_DIR/script_copy_plots.sh $NCL_PLOT_DIR $NEW_CGRER_HTML_DIR" } msg ]
puts $log $msg
flush $log

# create new webpage
  cd $WEBPAGE_DIR
  set sedcommand [open sedcommand.sed w+]
  puts $sedcommand "s,_SAAAA_,$saaaa,g"
  puts $sedcommand "s,_SMM_,$smm,g"
  puts $sedcommand "s,_SDD_,$sdd,g"
  puts $sedcommand "s,_SHH_,$gfs_run,g"
  close $sedcommand
  exec sed -f sedcommand.sed pshow.html.sed  > pshow.html
  exec sed -f sedcommand.sed pshow_crossection.html.sed  > pshow_crossection.html
#  exec sed -f sedcommand.sed pshow_vercross.html.sed  > pshow_vercross.html
  file delete -force sedcommand.sed

# copy new webpage
  set c [catch {eval "exec scp pshow.html pmenu.html pshow_crossection.html pmenu_crossection.html saide@nitrogen.acom.ucar.edu:$NEW_CGRER_HTML_DIR\/" } msg ]
puts $log $msg
flush $log

# make new webpage the current one
#  set c [catch {eval "exec ssh saide@nitrogen.acom.ucar.edu rm $CGRER_HTML_DIR\/wrf_aam-current" } msg ]
#  set c [catch {eval "exec ssh saide@nitrogen.acom.ucar.edu ln -s $NEW_CGRER_HTML_DIR $CGRER_HTML_DIR\/wrf_aam-current" } msg ]
  set c [catch {eval "exec ssh saide@nitrogen.acom.ucar.edu rm -r $CGRER_HTML_DIR\/wrf_aam-current" } msg ]
  set c [catch {eval "exec ssh saide@nitrogen.acom.ucar.edu cp -r $NEW_CGRER_HTML_DIR $CGRER_HTML_DIR\/wrf_aam-current" } msg ]
puts $log $msg
flush $log

# Run flight tracks
#  cd $MATLAB_OTHER_DIR  
#  set c [catch { eval "exec $qsub_1proc_cmd /usr/bin/ssh localhost \"${MATLAB_OTHER_DIR}/run_wrfaam_plots.sh $saaaa $smm $sdd $gfs_run $WRF_ANALYSIS_OUT $MATLAB_OTHER_DIR\" >& ${MATLAB_OTHER_DIR}/script_qsub.sh.run_wrfaam_plots_log" } msg ]
#  puts $log $msg
#  flush $log

# Copy flgiht tracks
#set MATLAB_PLOT_DIR [file join $WRF_ANALYSIS_OUT $week matlab_curtains]
#cd $WEBPAGE_OTHER_DIR
# set c [catch { eval "exec ./script_copy.sh WRFAAM ${MATLAB_PLOT_DIR} saide@nitrogen.acom.ucar.edu:${NEW_CGRER_HTML_DIR}" } msg ]
#puts $log $msg
#flush $log

# create new webpage
  cd $WEBPAGE_OTHER_DIR
  set sedcommand [open sedcommand.sed w+]
  puts $sedcommand "s,_SAAAA_,$saaaa,g"
  puts $sedcommand "s,_SMM_,$smm,g"
  puts $sedcommand "s,_SDD_,$sdd,g"
  puts $sedcommand "s,_SHH_,$gfs_run,g"
  close $sedcommand
  exec sed -f sedcommand.sed pshow_flight_track_wrfaam.html.sed  > pshow_flight_track_wrfaam.html
  file delete -force sedcommand.sed

# copy new webpage
  set c [catch {eval "exec scp pshow_flight_track_wrfaam.html pmenu_flight_track_wrfaam.html saide@nitrogen.acom.ucar.edu:$NEW_CGRER_HTML_DIR\/" } msg ]
puts $log $msg
flush $log

# Zip all in one file
  set c [catch {eval "exec ssh saide@nitrogen.acom.ucar.edu rm $CGRER_HTML_DIR\/wrf_aam-current.zip" } msg ]
  set c [catch {eval "exec ssh saide@nitrogen.acom.ucar.edu zip -9 -y -r -q $CGRER_HTML_DIR\/wrf_aam-current.zip $CGRER_HTML_DIR\/wrf_aam-current/" } msg ]
puts $log $msg
flush $log

# run vertical crossections
#cd $NCL_SCRIPT_DIR
#set c [catch { eval "exec ./run_vercross_check_fn.sh $wrf_aaaa\-$wrf_mm\-$wrf_dd\_$wrf_hh\:00:00 $WRF_ANALYSIS_OUT_week $WRF_NOFIRE_OUT_week $NCL_PLOT_DIR 0 0 1" } msg ]
#puts $log $msg
#flush $log
##20 min standby
#after 1200000
#puts $log "# Finished standby for vercross"
#flush $log

# copy vertical crossections
#set c [catch { eval "exec $NCL_SCRIPT_DIR/script_copy_vercross_plots.sh $NCL_PLOT_DIR $NEW_CGRER_HTML_DIR" } msg ]
#puts $log $msg
#flush $log

# copy new vertical crossections webpage
#cd $WEBPAGE_DIR
#set c [catch {eval "exec scp pshow_vercross.html pmenu_vercross.html saide@nitrogen.acom.ucar.edu:$NEW_CGRER_HTML_DIR\/" } msg ]
#puts $log $msg
#flush $log

}

if { $google == "yes" } {
   GOOGLE_shell
   }
##crontab_shell 0

puts $log "# REACHED END OF SCRIPT"
flush $log

exit
