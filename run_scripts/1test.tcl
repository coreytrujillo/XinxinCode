#!/usr/bin/wish -f

for {set x 0} {$x<5} {incr x} {
    if {$x > 2} {
        break
    }
    puts "x is $x"
}

puts "good"
    puts "x is $x"



  set saaaa 2019
  set smm 08 
  set sdd 02 
 
  puts  "Waiting: wait till 18:00 EDT"
  set c [catch {eval "exec date -d \"$saaaa-$smm-$sdd 18:00:00\"  +%s"} msg0 ]
  set c [catch {eval "exec date  +%s"} msg ]
  while { $msg< $msg0 } {
        exec sleep 5
        puts $msg 
        set c [catch {eval "exec date +%s"} msg ]
    }
