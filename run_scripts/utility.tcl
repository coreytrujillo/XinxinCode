#!/usr/bin/wish -f

# ---------------------------------------------------------
# - get_ftp {}
# ---------------------------------------------------------

 proc get_ftp {args} {
     
    package require ftp

    global HOME_DIR
    global timestep
    global log
 
    puts $log "[clock format [clock seconds] -format "%H:%M:%S" ] |I| get_ftp STARTS "

    # ---------------------------------------------------------
    # GET ARGUMENT
    # ---------------------------------------------------------

    set address [lindex $args 0]
    set user [lindex $args 1]
    set pass [lindex $args 2]
    set remdir [lindex $args 3]
    set locdir [lindex $args 4]
    set F_INP [lindex $args 5]
    set returnshell 0 
    puts $log "get_ftp arguments: $address $user $pass $remdir $locdir $F_INP"

    if { ![file exists $locdir]} {puts "[clock format [clock seconds] -format "%H:%M:%S" ] |E| get_ftp: $locdir doesn't exist"; END_shell}

    cd $locdir
    set try 1

    while {$try <= 3}  {
      puts $log "[clock format [clock seconds] -format "%H:%M:%S" ] |I| get_fpt: get $F_INP try $try"
      flush $log
      # START downloading
      set c [catch {ftp::Open $address $user $pass -mode passive} handle]
      if {$handle < 0} {puts $log "[clock format [clock seconds] -format "%H:%M:%S" ] |E| get_fpt: Connection error $address $user *****"; puts $log "ftp handle: $handle\n";incr try; continue}

      set c [catch {ftp::Cd $handle $remdir} returncd]
      if {$returncd != 1} {puts $log "[clock format [clock seconds] -format "%H:%M:%S" ] |E| get_fpt: Error changing directory $remdir"; puts $log "ftp returncd: $returncd\n";incr try; continue}

      set c [catch {ftp::ModTime $handle $F_INP} returntime]
      if {$returntime == "" || $c == 1} {puts $log "[clock format [clock seconds] -format "%H:%M:%S" ] |E| get_fpt: ModTime Error for $F_INP"; puts $log "ftp returntime: $returntime\n";incr try; continue}

      puts $log "[clock format [clock seconds] -format "%H:%M:%S" ] |I| get_fpt: $F_INP modification time [clock format $returntime -format "%Y %m %d %H:%M:%S"]" 

      set c [catch {ftp::Get $handle $F_INP} returnget]
      if {$returnget == 0 || $c == 1} {puts $log "[clock format [clock seconds] -format "%H:%M:%S" ] |E| get_fpt: Get Error for $F_INP"; puts $log "ftp returnget: $returnget\n";incr try; continue}

      set returnshell $returnget
      set c [catch {ftp::Close $handle} returnclose]
      puts $log "Close exit code: $returnclose"
      break
      }

    cd $HOME_DIR
    puts $log "[clock format [clock seconds] -format "%H:%M:%S" ] |I| get_ftp END "
    flush $log
    return $returnshell
}

# ---------------------------------------------------------
#
#
#
#
#
# ---------------------------------------------------------
 proc crontab_shell {args} {

     global log
     global HOME_DIR
     global HOUR_START
     global HOUR_END
     global WRF_OUT 
     set mod [lindex $args 0]
     set now_hour [clock format [clock seconds] -format %H ]
     set cron_h   [clock format [clock scan "15 min"] -format %H]
     set cron_min [clock format [clock scan "15 min"] -format %M]

     if {$mod != 0 && $now_hour<=$HOUR_END} {
        set cron_id [open crontab_file w]
        puts $cron_id "$cron_min $cron_h * * * [file join $HOME_DIR r_wrf.bash] >& [file join $WRF_OUT SAFAR_OUT.log]" 
        close $cron_id
        eval "exec crontab [file join $HOME_DIR crontab_file]"
        } else {
        set cron_id [open crontab_file w]
        puts $cron_id "0 $HOUR_START * * * [file join $HOME_DIR r_wrf.bash] >& [file join $WRF_OUT SAFAR_OUT.log]"
        close $cron_id
        eval "exec crontab [file join $HOME_DIR crontab_file]"
        }

     if {$mod != 0} {
        if {$now_hour<=$HOUR_END} {
            puts $log "[clock format [clock seconds] -format "%H:%M:%S" ] |W| NO DATA"
            puts $log "[clock format [clock seconds] -format "%H:%M:%S" ] |W| crontab_shell: SCHEDULER +15mm"
            } else {
            puts $log "[clock format [clock seconds] -format "%H:%M:%S" ] |E| NO DATA"
            puts $log "[clock format [clock seconds] -format "%H:%M:%S" ] |E| crontab_shell: SCHEDULER TOMORROW"
            }
	END_shell 1
        } else {
        puts $log "[clock format [clock seconds] -format "%H:%M:%S" ] |I| crontab_shell: SCHEDULER TOMORROW"
	END_shell 0
        }
     	
 }

# --------------------------------------------
#  FTP: Put a file into a remote directory
#  If 'filename' is a list, it transfer each file
#  without rename and 'filerem' will be considered
#  as remote directory.
#  In case single 'filename', the file name could be
#  changed if 'filerem' is given
# --------------------------------------------
proc FTP_CHECK {arg} {
package require ftp
package require log

global LOG_ROOT
global LOGFTP_error 

  set mod $arg
  if  {$mod=="A"} {
    set LOGFTP_error [open [file join $LOG_ROOT ftp_error.log ] w+]
    log::lvChannel error $LOGFTP_error
    return 1
  } elseif  {$mod=="C"} {
    close $LOGFTP_error 
    set size [file size [file join $LOG_ROOT ftp_error.log ]]
    if {$size != 0} {
        set LOGFTP_error [open [file join $LOG_ROOT ftp_error.log ] r]
        puts "FTP_CHECK: [read -nonewline $LOGFTP_error]"
        close $LOGFTP_error 
        return 0
        }
        return 1
  }      
}      
##############################################################
#PROCEDURE
##############################################################
# --------------------------------------------
# FTP: delete every files
# into a remote directory
# --------------------------------------------
proc FTP_Deldir {address user pwd remdir} {
package require ftp
package require log

  set timeout 600
#  set nameproc [PutsNameProc -1]
  set nameproc ftp_del
  puts "\nStart of $nameproc: server $address, user $user, pwd $pwd\n"

  #---- Open the connection
  set handle [ftp::Open $address $user $pwd -mode passive -timeout $timeout]

  puts "handle=$handle"
  if {$handle == -1} {
    putsError "*** $nameproc: Connection error $address $user ***"
    return 0
  }

  set ok [ftp::Cd $handle $remdir]
  if {$ok==0} {
    ftp::Close $handle
    putsError "*** $nameproc: Change directory error ***"
    return 0
  }
  set filelist [ftp::NList $handle]
  if {$filelist==""} {puts "Remote directory already empty" ; return 1}
  puts "\n** Files to delete **\n$filelist"
  foreach filename $filelist {ftp::Delete $handle $filename}
  ftp::Close $handle
  return 1
}
# --------------------------------------------
#  FTP: Put a file into a remote directory
#  If 'filename' is a list, it transfer each file
#  without rename and 'filerem' will be considered
#  as remote directory.
#  In case single 'filename', the file name could be
#  changed if 'filerem' is given
# --------------------------------------------
proc FTP_Put {address user pwd filename {filerem ""} {type binary}} {
package require ftp
package require log

global LOGFTP_error 
 
#  set ftp::VERBOSE 1
  set nameproc ftp_put
  set timeout 600
  set code 1
  set notdone {}
  
  #---- Open the connection
  set handle [ftp::Open $address $user $pwd -mode passive -timeout $timeout]

  puts "handle=$handle"
  if {$handle == -1} {
    puts "*** $nameproc: Connection error $address $user ***"
    return 0
  }

  set filelist $filename
  if {[llength $filelist]>1} {;# c'è una lista
    if {$filerem != ""} {set remdir $filerem}
    set filerem ""
    puts "Local file list of [llength $filelist] files"
  } else {;# è un file solo
    puts "Local file $filename"
    if {$filerem == ""} {
      set filerem [file tail $filename]
    } else {
      set lista [file split $filerem]
      set remdir [join [lrange $lista 0 end-1] /]
      set filerem [file tail $filerem]
    }
    puts "Remote file $filerem"
  }

  #---- Change the remote directory (if necessary)
  if {[info exist remdir]} {
    puts "Change the remote directory $remdir"
    set ok [ftp::Cd $handle $remdir]
    if {$ok==0} {
      ftp::Close $handle
      puts "*** $nameproc: Change directory error ***"
      return -1
    }
  }

  #---- Put file(s)
  puts "Transfer file type: $type"
  set loop 3  ;# max di tentativi
  set notdone {}
  set totfile [llength $filelist]
  set nfile 0

  foreach filename $filelist {
    incr nfile
    set lsize [file size $filename]
    if {$filerem!=""} {set fileftp $filerem} else {set fileftp [file tail $filename]}
    set ret -99
    set iter 0
    while {$iter<$loop} {
      incr iter
      update idletasks

      if {$ret==0} {  ;# ERROR
        #---- close
#        ftp::Close $handle
        set handle -1
        set ntry 0
        #---- open again
        while {$handle==-1 && $ntry<$loop} {
          puts "ftp::reOpen"    
          set handle [ftp::Open $address $user $pwd -mode passive -timeout $timeout]
          incr ntry
        }
        #---- exit if open failed
        if {$ntry==$loop} {
          puts "*** $nameproc: Connection failed during the file transfer ***"
          return 0
        }
        #---- cd
        if {[info exist remdir]} {ftp::Cd $handle $remdir}
      }

      #---- put
      
      FTP_CHECK A
      puts "ftp::Type"    
      ftp::Type $handle $type
      set ret [FTP_CHECK C]
      if {$ret == 0} {continue } 
      FTP_CHECK A
      puts "ftp::Put"    
      set c [catch {puts [ftp::Put $handle $filename $fileftp] ]} msg ]
      if {$c == 1 && $msg != 0} {puts "Put Std Error: $msg"}
      set ret [FTP_CHECK C]
      if {$ret == 0} {continue } 
      #---- Check the return status
      if {$ret!= 0} {  ;# TRANSFER DONE
        #---- check remote file size
        FTP_CHECK A
        puts "ftp::Type"    
        ftp::Type $handle binary
        set ret [FTP_CHECK C]
        if {$ret == 0} {continue } 
        # FileSize only works proper in binary mode
        FTP_CHECK A
        puts "ftp::FileSize"    
        set rsize [ftp::FileSize $handle $fileftp]
        set ret [FTP_CHECK C]
        if {$ret == 0} {continue } 
        if {$lsize==$rsize} {break}
        puts "Original File:\t$lsize bytes"
        puts "Stored File:\t$rsize bytes"
        set ret 0
      }
    }
    #---- transfer of this file terminated ?
    if {$iter<$loop} {
      puts "File $nfile/$totfile: $filename copied to remote $fileftp ($iter/$loop)"
    } else {
      puts "*** $nameproc: Impossible to write the remote file $fileftp ***"
      set code -2
      lappend notdone $filename
    }
  }

  puts "Transfer done"
  ftp::Close $handle

  return [list $code $notdone]

}   ;# ftp_put
# --------------------------------------------
# dirDialog --
# fine procedura
# --------------------------------------------

proc END_shell {{arg -999}} {

    global log
    global flog
    global mail

    set errmes $arg

    puts $log "#------------------------------------------------------------------"
    puts $log "SYSTEM CLOCK: [clock format [clock seconds] -format "%a, %d %b %Y %H:%M:%S" ]"

    if {$errmes == 0} {
         puts $log "*** END PROCEDURE OK ***"
         close $log
	 if {$mail == "yes"} {
            puts "mail pablo-saide@uiowa.edu -s \"SEAC4RS done\" < $flog" 
            set c [catch [eval exec mail pablo-saide@uiowa.edu -c pablosaide@gmail.com -s \"SEAC4RS done\" < $flog  ] msg]
       	    puts $msg
            }
       } elseif { $errmes == 1 } { 
         puts $log "*** END PROCEDURE WITH ERROR ***"
         close $log
         if {$mail == "yes"} {
            puts "mail pablo-saide@uiowa.edu -s \"SEAC4RS exit with Error\" < $flog" 

            set c [catch [eval exec mail  pablo-saide@uiowa.edu -c pablosaide@gmail.com -s \"SEAC4RS exit with Error\" < $flog ] msg]
            puts $msg
	    }
       } else {
         puts $log "*** END PROCEDURE ***"
         close $log
       }
    exit
}
