# Create a new simulator
set ns [new Simulator]

# Set colors for diffrent flows
$ns color 1 Blue
$ns color 2 Red
$ns color 3 Yellow

# Open the animator file
set tcp_nam_file [open tcp.nam w]
$ns namtrace-all $tcp_nam_file

# Open the trace file
set tcp_trace_file [open tcp.tr w]
$ns trace-all $tcp_trace_file

# Open the file to track throughput for xgraph
set tcp_winfile [open tcp-throughput.tr w]

# Open the file to track packet loss for xgraph
set tcp_pacfile [open tcp-packetloss.tr w]

# Finish procedure to terminate the program
proc finish {} {
    global ns tcp_nam_file tcp_trace_file tcp_winfile tcp_pacfile
    $ns flush-trace
    close $tcp_nam_file
    close $tcp_trace_file
    close $tcp_winfile
    close $tcp_pacfile
    exec nam tcp.nam &
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

# Declare three TCP sources
set tcp1 [new Agent/TCP]
$ns attach-agent $n(0) $tcp1
$tcp1 set class_ 1
$tcp1 set fid_ 1

set tcp2 [new Agent/TCP]
$ns attach-agent $n(2) $tcp2
$tcp2 set class_ 2
$tcp2 set fid_ 2

set tcp3 [new Agent/TCP]
$ns attach-agent $n(3) $tcp3
$tcp3 set class_ 3
$tcp3 set fid_ 3

# Three sinks for the three sources
set sink1 [new Agent/TCPSink]
set sink2 [new Agent/TCPSink]
set sink3 [new Agent/TCPSink]

# Last node is the common sink for all sources
$ns attach-agent $n([expr {$num_nodes - 1}]) $sink1
$ns attach-agent $n([expr {$num_nodes - 1}]) $sink2
$ns attach-agent $n([expr {$num_nodes - 1}]) $sink3

# Connect the source with its corresponding sink
$ns connect $tcp1 $sink1
$ns connect $tcp2 $sink2
$ns connect $tcp3 $sink3

# Set up FTP over TCP for the connections
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ftp1 set type_ FTP

set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2
$ftp2 set type_ FTP

set ftp3 [new Application/FTP]
$ftp3 attach-agent $tcp3
$ftp3 set type_ FTP

# Procedure to be called every 1 second to track throughput and packetloss
# Set the 'tick' variable on line 119 to a different value to change the delay between recursive calls 
proc record {} {
        global tcp_winfile tcp_pacfile sink1 sink2 sink3
        #Get an instance of the simulator
        set ns [Simulator instance]
        #Set the time after which the procedure should be called again
        set tick 1
        #How many bytes have been received by the traffic sinks?
        set bw1 [$sink1 set bytes_]
        set bw2 [$sink2 set bytes_]
        set bw3 [$sink3 set bytes_]

        set bw [expr {$bw1 + $bw2 + $bw3}]
        #Get the current time
        set now [$ns now]

        #Calculate the throughput (in MBit/s) and write it to the files
        puts $tcp_winfile "$now [expr $bw/$now*8/1000000]"

        #Calculate packet loss
        puts $tcp_pacfile "$now [exec awk -v now=$now -v toNode=9 -f packet_loss.awk tcp.tr]"

        #Reset the bytes_ values on the traffic sinks
        $sink1 set bytes_ 0
        $sink2 set bytes_ 0
        $sink3 set bytes_ 0

        #Re-schedule the procedure
        $ns at [expr $now+$tick] "record"
}

$ns at 0.05 "record"
$ns at 0.1 "$ftp1 start"
$ns at 0.1 "$ftp2 start"
$ns at 0.1 "$ftp3 start"
$ns at 4.5 "$ftp1 stop"
$ns at 4.5 "$ftp2 stop"
$ns at 4.5 "$ftp3 stop"

$ns at 4.5 "$ns detach-agent $n(0) $tcp1; $ns detach-agent $n([expr {$num_nodes - 1}]) $sink1"
$ns at 4.5 "$ns detach-agent $n(2) $tcp2; $ns detach-agent $n([expr {$num_nodes - 1}]) $sink2"
$ns at 4.5 "$ns detach-agent $n(3) $tcp3; $ns detach-agent $n([expr {$num_nodes - 1}]) $sink3"

$ns at 5.0 "finish"

$ns run
