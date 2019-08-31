# ---------------------------------------------------------
# -GOOGLE_shell {}
#
# Procedura che scrive il file di appoggio: FARM.ini
#
# Chiamato da:
#
#
# ---------------------------------------------------------
 proc GOOGLE_shell {} {

     global log
     global data
     global shh
     global timestep

     set LAY "8 10 12 15"
     array set LAY_name {8 1,5km  10  3,5km 12 5,5km 15 8,8km} 
     set SPEC3D "bc co beijing  hg rh"
     set SPEC2D "prate totalaod"
#     set SPEC3D "bc co biomco hg"
     array set SPEC_name {bc BC co Anthropogenic_CO beijing  Beijing_CO hg Mercury prate Precipitation rh RH totalaod Total_AOD}
#     array set SPEC_name {bc BC co Anthropogenic_CO biomco Biomass_CO hg Mercury} 
   
# ---------------------------------------------------------
# gestione date
# ---------------------------------------------------------
puts $log "[clock format [clock seconds] -format "%H:%M:%S" ] |I| GOOGLE_shell running"

append sdata  [lindex $data 0] [lindex $data 1] [lindex $data 2]
#    write kml file


#    google overlay geo references

     set north    "90"
     set south    "6"
     set east     "360"
     set west     "0"

#    write project dipendet parameters

#   my run starts at 18Z I move 6 hours ahead 0Z of the day after
    set sdata [expr [clock scan $sdata]+[expr $shh * 3600]+[expr 6*3600]]

    set out [open /data/raid4/html/ARCTAS/KMLfiles/KMLarchive/ARCTAS_[clock format $sdata -format %m]-[clock format $sdata -format %d]\.kml w+]

    set OUT_ROOT "http://www.cgrer.uiowa.edu/ARCTAS/KMLfiles"
    set OUT_DIR "$OUT_ROOT\/[clock format $sdata -format %m]-[clock format $sdata -format %d]"

     puts $out "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
     puts $out "<kml xmlns=\"http://earth.google.com/kml/2.2\">"
     puts $out "<Folder>"
     puts $out "        <name>ARCTAS</name>"
     puts $out "	<open>1</open>"
     puts $out "                <LookAt>"
     puts $out "                <longitude>-97.09417630373082</longitude>"
     puts $out "                <latitude>58.67345977514282</latitude>"
     puts $out "                <altitude>0</altitude>"
     puts $out "                <range>6589675.762806191</range>"
     puts $out "                <tilt>8.754935315511494</tilt>"
     puts $out "                <heading>-4.328935180979842</heading>"
     puts $out "                <altitudeMode>relativeToGround</altitudeMode>"
     puts $out "                </LookAt>"
     puts $out "        <Folder>"
     puts $out "                <name>[clock format $sdata -format %Y][clock format $sdata -format %m][clock format $sdata -format %d]</name>"
     puts $out "                <Style>"
     puts $out "                <ListStyle>"
     puts $out "                <listItemType>radioFolder</listItemType>"
     puts $out "                <bgColor>00ffffff</bgColor>"
     puts $out "                </ListStyle>"
     puts $out "                </Style>"
     puts $out "	        <open>1</open>"
     foreach spec $SPEC3D {
      puts $out "                <Folder>"
      puts $out "                      <name>$SPEC_name($spec)</name>"
      puts $out "                      <ScreenOverlay>"
      puts $out "                              <name>Color scale</name>"
      puts $out "                              <Icon>"
      puts $out "                                      <href>$OUT_ROOT\/Colorbars/$spec\_bar.gif</href>"
      puts $out "                              </Icon>"
      puts $out "                              <overlayXY x=\"0\" y=\"0\" xunits=\"fraction\" yunits=\"fraction\"/>"
      puts $out "                              <screenXY x=\"0\" y=\".93\" xunits=\"fraction\" yunits=\"fraction\"/>"
      puts $out "                              <rotationXY x=\"0.5\" y=\"0.5\" xunits=\"fraction\" yunits=\"fraction\"/>"
      puts $out "                              <size x=\"498\" y=\"28\" xunits=\"pixel\" yunits=\"pixel\"/>"
      puts $out "                      </ScreenOverlay>"
      foreach layer $LAY {
       puts $out "                      <Folder>"
       puts $out "                             <name>$LAY_name($layer)\</name>"
       for {set i 0} {$i <= [expr $timestep-6]} {incr i 6} {
        set datanow [expr $sdata + [expr $i*3600]]
        set saaaa [clock format $datanow -format %Y]
        set smm   [clock format $datanow -format %m]
        set sgg   [clock format $datanow -format %d]
        set shh   [clock format $datanow -format %H]

        set datanow [expr $sdata + [expr ($i+6)*3600]]
        set eaaaa [clock format $datanow -format %Y]
        set emm   [clock format $datanow -format %m]
        set egg   [clock format $datanow -format %d]
        set ehh   [clock format $datanow -format %H]
        puts $out "                             <GroundOverlay>"
        puts $out "                             <name>$spec\+[format "%02u" $i]h</name>"
        puts $out "                             <TimeSpan>"
        puts $out "                             <begin>$saaaa\-$smm\-$sgg\T$shh\:00:00Z</begin>"
        puts $out "                             <end>$eaaaa\-$emm\-$egg\T$ehh\:00:00Z</end>"
        puts $out "                             </TimeSpan>"
        puts $out "                             <Icon>"
        puts $out "                             <href>$OUT_DIR\/$layer\/$spec\+[format "%02u" $i]h.gif</href>"
        puts $out "                             </Icon>"
        puts $out "                             <LatLonBox>"
        puts $out "                             <north>$north\</north>"
        puts $out "                             <south>$south\</south>"
        puts $out "                             <east>$east\</east>"
        puts $out "                             <west>$west\</west>"
        puts $out "                             </LatLonBox>"
        puts $out "                             </GroundOverlay>"
        }
       puts $out "                      </Folder>"
       }
      puts $out "                </Folder>"
      }
     foreach spec $SPEC2D {
      puts $out "                <Folder>"
      puts $out "                      <name>$SPEC_name($spec)</name>"
      puts $out "                      <ScreenOverlay>"
      puts $out "                              <name>Color scale</name>"
      puts $out "                              <Icon>"
      puts $out "                                      <href>$OUT_ROOT\/Colorbars/$spec\_bar.gif</href>"
      puts $out "                              </Icon>"
      puts $out "                              <overlayXY x=\"0\" y=\"0\" xunits=\"fraction\" yunits=\"fraction\"/>"
      puts $out "                              <screenXY x=\"0\" y=\".93\" xunits=\"fraction\" yunits=\"fraction\"/>"
      puts $out "                              <rotationXY x=\"0.5\" y=\"0.5\" xunits=\"fraction\" yunits=\"fraction\"/>"
      puts $out "                              <size x=\"498\" y=\"28\" xunits=\"pixel\" yunits=\"pixel\"/>"
      puts $out "                      </ScreenOverlay>"
      puts $out "                      <Folder>"
      puts $out "                             <name>Ground</name>"
      set deltaend 6
      if {$spec == "totalaod" }  {set deltaend 12}
      for {set i 0} {$i <= [expr $timestep-$deltaend]} {incr i 6} {
        set datanow [expr $sdata + [expr $i*3600]]
        set saaaa [clock format $datanow -format %Y]
        set smm   [clock format $datanow -format %m]
        set sgg   [clock format $datanow -format %d]
        set shh   [clock format $datanow -format %H]

        set datanow [expr $sdata + [expr ($i+6)*3600]]
        set eaaaa [clock format $datanow -format %Y]
        set emm   [clock format $datanow -format %m]
        set egg   [clock format $datanow -format %d]
        set ehh   [clock format $datanow -format %H]
        puts $out "                             <GroundOverlay>"
        puts $out "                             <name>$spec\+[format "%02u" $i]h</name>"
        puts $out "                             <TimeSpan>"
        puts $out "                             <begin>$saaaa\-$smm\-$sgg\T$shh\:00:00Z</begin>"
        puts $out "                             <end>$eaaaa\-$emm\-$egg\T$ehh\:00:00Z</end>"
        puts $out "                             </TimeSpan>"
        puts $out "                             <Icon>"
        puts $out "                             <href>$OUT_DIR\/2d\/$spec\+[format "%02u" $i]h.gif</href>"
        puts $out "                             </Icon>"
        puts $out "                             <LatLonBox>"
        puts $out "                             <north>$north\</north>"
        puts $out "                             <south>$south\</south>"
        puts $out "                             <east>$east\</east>"
        puts $out "                             <west>$west\</west>"
        puts $out "                             </LatLonBox>"
        puts $out "                             </GroundOverlay>"
        }
      puts $out "                     </Folder>"
      puts $out "                </Folder>"
      }
     puts $out "        </Folder>"
     puts $out "</Folder>"
     puts $out "</kml>"
     close $out
}
