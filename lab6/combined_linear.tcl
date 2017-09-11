# Create a new simulator
set ns [new Simulator]

# Set colors for diffrent flows
$ns color 1 Blue
$ns color 2 Red

# Open the animator file
set combined_nam_file [open combined.nam w]
$ns namtrace-all $combined_nam_file

# Open the trace file
set combined_trace_file [open combined.tr w]
$ns trace-all $combined_trace_file

# Open the file to track throughput for xgraph
set combined_winfile [open combined-throughput.tr w]

# Open the file to track packet loss for xgraph
set combined_pacfile [open combined-packetloss.tr w]

# Finish procedure to terminate the program
proc finish {} {
    global ns combined_nam_file combined_trace_file combined_winfile combined_pacfile
    $ns flush-trace
    close $combined_nam_file
    close $combined_trace_file
    close $combined_winfile
    close $combined_pacfile
    exec nam combined.nam &
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
# TCP requires acknowledgement, so use duplex-links
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

# Declare a TCP source
set tcp1 [new Agent/TCP]
$ns attach-agent $n(0) $tcp1
$tcp1 set class_ 1
$tcp1 set fid_ 1

# Declare a UDP source
set udp1 [new Agent/UDP]
$ns attach-agent $n(2) $udp1
$udp1 set class_ 2
$udp1 set fid_ 2

# Two sinks for the two sources
set sink1 [new Agent/TCPSink]
set sink2 [new Agent/Null]

# Last node is the common sink for all sources
$ns attach-agent $n([expr {$num_nodes - 1}]) $sink1
$ns attach-agent $n([expr {$num_nodes - 1}]) $sink2

# Connect the source with its corresponding sink
$ns connect $tcp1 $sink1
$ns connect $udp1 $sink2

# Set up FTP over TCP for the connections
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ftp1 set type_ FTP

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

# Procedure to be called every 1 second to track throughput and packetloss
# Set the 'tick' variable on line 115 to a different value to change the delay between recursive calls 
proc record {} {
        global combined_winfile combined_pacfile packet_sz sink1 sink2
        #Get an instance of the simulator
        set ns [Simulator instance]
        #Set the time after which the procedure should be called again
        set tick 1
        #How many bytes have been received by the traffic sinks?
        set bw [$sink1 set bytes_]

        #Get the current time
        set now [$ns now]

        #Calculate the throughput (in MBit/s) and write it to the files
        set udp_thru [exec awk -v now=$now -v toNode=9 -v packet_sz=$packet_sz -f udp_throughput.awk combined.tr]
        set tcp_thru [expr $bw/$now*8/1000000]

        puts $combined_winfile "$now [expr {$tcp_thru + $udp_thru}]"

        #Calculate packet loss
        puts $combined_pacfile "$now [exec awk -v now=$now -v toNode=9 -f packet_loss.awk combined.tr]"

        #Reset the bytes_ values on the traffic sinks
        $sink1 set bytes_ 0

        #Re-schedule the procedure
        $ns at [expr $now+$tick] "record"
}

$ns at 0.05 "record"
$ns at 0.1 "$ftp1 start"
$ns at 0.1 "$cbr1 start"
$ns at 4.5 "$ftp1 stop"
$ns at 4.5 "$cbr1 stop"

$ns at 4.5 "$ns detach-agent $n(0) $tcp1; $ns detach-agent $n([expr {$num_nodes - 1}]) $sink1"
$ns at 4.5 "$ns detach-agent $n(2) $udp1; $ns detach-agent $n([expr {$num_nodes - 1}]) $sink2"

$ns at 5.0 "finish"

$ns run
