# Create new simulator
set ns [new Simulator]

# Set colors for different flows
$ns color 1 Blue
$ns color 2 Red
$ns color 3 Yellow

# Open file for animator
set udp_nam_file [open udp.nam w]
$ns namtrace-all $udp_nam_file

# Open file for trace
set udp_trace_file [open udp.tr w]
$ns trace-all $udp_trace_file

# Open the file to track throughput for xgraph
set udp_winfile [open udp-throughput.tr w]

# Open the file to track packet loss for xgraph
set udp_pacfile [open udp-packetloss.tr w]

# Finish procedure to terminate the program
proc finish {} {
    global ns udp_nam_file udp_trace_file udp_winfile udp_pacfile
    $ns flush-trace
    close $udp_nam_file
    close $udp_trace_file
    close $udp_winfile
    close $udp_pacfile
    exec nam udp.nam &
    exit 0
}

# Variable to set number of nodes (Use any value of your choice :D)
set num_nodes 10 

# Queue type taken as command line argument
# Run your program with "ns <filename> <DropTail|RED|SFQ>"
set qtype [lindex $argv 0]

# Create nodes
for {set i 0} {$i < $num_nodes} {incr i} {
    set n($i) [$ns node]
}

# Establish links between nodes
for {set i 0} {$i < [expr {$num_nodes - 2}]} {incr i} {
    $ns duplex-link $n($i) $n([expr {$i + 1}]) 2Mb 10ms $qtype
}

# Set the last link having lower capacity and greater propagation delay to observe packet drops
$ns duplex-link $n([expr {$num_nodes - 2}]) $n([expr {$num_nodes - 1}]) 1Mb 20ms $qtype

# Set the queue limit to 8 for the last link
# Default is 50 (pretty large, so you won't observe significant packet drops)
$ns queue-limit $n([expr {$num_nodes - 2}]) $n([expr {$num_nodes - 1}]) 8

# Set orientaion (just to make it look good)
for {set i 0} {$i < [expr {$num_nodes - 1}]} {incr i} {
    $ns duplex-link-op $n($i) $n([expr {$i + 1}]) orient right
}

# Monitor the queue at the last (for the "queue filling up" animation)
$ns duplex-link-op $n([expr {$num_nodes - 2}]) $n([expr {$num_nodes - 1}]) queuePos 0.5
#$ns duplex-link-op $n(23) $n(24) queuePos 0.5

# Declare three UDP sources
set udp1 [new Agent/UDP]
$ns attach-agent $n(0) $udp1
$udp1 set class_ 1
$udp1 set fid_ 1

set udp2 [new Agent/UDP]
$ns attach-agent $n(2) $udp2
$udp2 set class_ 2
$udp2 set fid_ 2

set udp3 [new Agent/UDP]
$ns attach-agent $n(3) $udp3
$udp3 set class_ 3
$udp3 set fid_ 3

# Three sinks for the three sources
set sink1 [new Agent/Null]
set sink2 [new Agent/Null]
set sink3 [new Agent/Null]

# Last node is the common sink for all sources
$ns attach-agent $n([expr {$num_nodes - 1}]) $sink1
$ns attach-agent $n([expr {$num_nodes - 1}]) $sink2
$ns attach-agent $n([expr {$num_nodes - 1}]) $sink3

# Connect the source with its corresponding sink
$ns connect $udp1 $sink1
$ns connect $udp2 $sink2
$ns connect $udp3 $sink3

# Packet size and interval
# Set it to anything of your choice
set packet_sz 1000
set intvl 0.01

# Set up CBR over UDP for the connections
set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp1
$cbr1 set type_ CBR
$cbr1 set packetSize_ $packet_sz
$cbr1 set interval_ $intvl

set cbr2 [new Application/Traffic/CBR]
$cbr2 attach-agent $udp2
$cbr2 set type_ CBR
$cbr2 set packetSize_ $packet_sz
$cbr2 set interval_ $intvl

set cbr3 [new Application/Traffic/CBR]
$cbr3 attach-agent $udp3
$cbr3 set type_ CBR
$cbr3 set packetSize_ $packet_sz
$cbr3 set interval_ $intvl

# Procedure to be called every 1 second to track throughput and packetloss
# Set the 'tick' variable on line 130 to a different value to change the delay between recursive calls 
proc record {} {
        global udp_winfile udp_pacfile sink1 sink2 sink3 packet_sz
        #Get an instance of the simulator
        set ns [Simulator instance]
        #Set the time after which the procedure should be called again
        set tick 1
        #Get the current time
        set now [$ns now]

        #Calculate the throughput (in MBit/s) and write it to the files
        puts $udp_winfile "$now [exec awk -v now=$now -v toNode=9 -v packet_sz=$packet_sz -f udp_throughput.awk udp.tr]"

        #Calculate packet loss
        puts $udp_pacfile "$now [exec awk -v now=$now -v toNode=9 -f packet_loss.awk udp.tr]"

        #Re-schedule the procedure
        $ns at [expr $now+$tick] "record"
}

$ns at 0.05 "record"
$ns at 0.1 "$cbr1 start"
$ns at 0.1 "$cbr2 start"
$ns at 0.1 "$cbr3 start"
$ns at 4.5 "$cbr1 stop"
$ns at 4.5 "$cbr2 stop"
$ns at 4.5 "$cbr3 stop"

$ns at 4.5 "$ns detach-agent $n(0) $udp1; $ns detach-agent $n([expr {$num_nodes - 1}]) $sink1"
$ns at 4.5 "$ns detach-agent $n(2) $udp2; $ns detach-agent $n([expr {$num_nodes - 1}]) $sink2"
$ns at 4.5 "$ns detach-agent $n(3) $udp3; $ns detach-agent $n([expr {$num_nodes - 1}]) $sink3"

$ns at 5.0 "finish"

$ns run
