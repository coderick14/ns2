set routing_protocol   [lindex $argv 0]
# set transmission_range [lindex $argv 1]

set val(chan)             Channel/WirelessChannel     ;# channel type
set val(prop)             Propagation/TwoRayGround    ;# radio-propagation model
set val(netif)            Phy/WirelessPhy             ;# network interface type
set val(mac)              Mac/802_11                  ;# MAC type
set val(ifq)              Queue/DropTail/PriQueue     ;# interface queue type
set val(ll)               LL                          ;# link layer type
set val(ant)              Antenna/OmniAntenna         ;# antenna model
set val(ifqlen)           50                          ;# max packet in ifq
set val(nn)               3                           ;# number of mobilenodes
set val(rp)               $routing_protocol           ;# routing protocol
set val(x)                500                         ;# X dimension of topography
set val(y)                400                         ;# Y dimension of topography
set val(stop)             5                           ;# time of simulation end

$val(netif) set CPThresh_ 10.0
# $val(netif) set CSThresh_ 3.65262e-10 ;#250m
# $val(netif) set RXThresh_ 3.65262e-10 ;#250m
$val(netif) set CSThresh_ 2.28289e-11 ;#500m
$val(netif) set RXThresh_ 2.28289e-11 ;#500m
$val(netif) set Rb_ 2*1e6
$val(netif) set Pt_ 0.2818
$val(netif) set freq_ 914e+6
$val(netif) set L_ 1.0

set ns [new Simulator]

set tracefd  [open manet.tr w]
set namtrace [open manet.nam w]

$ns trace-all $tracefd
$ns namtrace-all-wireless $namtrace $val(x) $val(y)

set topo [new Topography]

$topo load_flatgrid $val(x) $val(y)

create-god $val(nn)
set chan_ [new $val(chan)]

$ns node-config -adhocRouting   $val(rp)     \
                -llType         $val(ll)     \
                -macType        $val(mac)    \
                -ifqType        $val(ifq)    \
                -ifqLen         $val(ifqlen) \
                -antType        $val(ant)    \
                -propType       $val(prop)   \
                -phyType        $val(netif)  \
                -channel        $chan_       \
                -topoInstance   $topo        \
                -agentTrace     ON           \
                -routerTrace    ON           \
                -macTrace       OFF          \
                -movementTrace  ON


proc finish {} {
    global ns tracefd namtrace
    $ns flush-trace
    close $tracefd
    close $namtrace
    # exec nam manet.nam &
    # exit 0
}

for {set i 0} {$i < $val(nn)} {incr i} {
    set node_($i) [$ns node]
}

$node_(0) set X_ 5.0
$node_(0) set Y_ 5.0
$node_(0) set Z_ 0.0

$node_(1) set X_ 490.0
$node_(1) set Y_ 285.0
$node_(1) set Z_ 0.0

$node_(2) set X_ 150.0
$node_(2) set Y_ 240.0
$node_(2) set Z_ 0.0

$ns at 0.5 "$node_(0) setdest 250.0 250.0 50.0"
$ns at 0.7 "$node_(1) setdest 45.0 285.0 60.0"

set tcp [new Agent/TCP]
set sink [new Agent/TCPSink]
$tcp set class_ 2

$ns attach-agent $node_(0) $tcp
$ns attach-agent $node_(1) $sink

$ns connect $tcp $sink

set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 0.5 "$ftp start"

for {set i 0} {$i < $val(nn)} {incr i} {
    $ns initial_node_pos $node_($i) 30
}

for {set i 0} {$i < $val(nn)} {incr i} {
    $ns at $val(stop) "$node_($i) reset"
}

$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "finish"
$ns at 5.1 "puts \"NS Exiting\"; $ns halt"

$ns run
