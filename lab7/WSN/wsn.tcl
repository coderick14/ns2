
# Define options
set val(chan) Channel/WirelessChannel ;# channel type
set val(prop) Propagation/TwoRayGround ;# radio-propagation model
set val(netif1) Phy/WirelessPhy ;# network interface type
set val(netif2) Phy/WirelessPhy ;# network interface type
set val(mac) Mac/802_11 ;# MAC type
set val(ifq) Queue/DropTail/PriQueue ;# interface queue type
set val(ll) LL ;# link layer type
set val(ant) Antenna/OmniAntenna ;# antenna model
set val(ifqlen) 50 ;# max packet in ifq
set val(nn) 6 ;# number of mobilenodes
set val(rp) AODV ;# routing protocol
set val(x) 600 ;# X dimension of topography
set val(y) 600 ;# Y dimension of topography
set val(stop) 10.0 ;# time of simulation end
set val(energymodel) EnergyModel ;#Energy set up

# Simulator Instance Creation
set ns [new Simulator]

set tracefd  [open wsn.tr w]
set namtrace [open wsn.nam w]

$ns trace-all $tracefd
$ns namtrace-all-wireless $namtrace $val(x) $val(y)
$ns eventtrace-all

# set up topography object
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

# general operational descriptor- storing the hop details in the network
create-god $val(nn)

#Transmission range setup

#********************************** UNITY GAIN, 1.5m HEIGHT OMNI DIRECTIONAL ANTENNA SET UP **************

Antenna/OmniAntenna set X_ 0
Antenna/OmniAntenna set Y_ 0
Antenna/OmniAntenna set Z_ 1.5
Antenna/OmniAntenna set Gt_ 1.0
Antenna/OmniAntenna set Gr_ 1.0

#********************************** SET UP COMMUNICATION AND SENSING RANGE ***********************************

#default communication range 250m

# Initialize the SharedMedia interface with parameters to make
# it work like the 914MHz Lucent WaveLAN DSSS radio interface
$val(netif1) set CPThresh_ 10.0
$val(netif1) set CSThresh_ 2.28289e-11 ;#sensing range of 500m
$val(netif1) set RXThresh_ 2.28289e-11 ;#communication range of 500m
$val(netif1) set Rb_ 2*1e6
$val(netif1) set Pt_ 0.2818
$val(netif1) set freq_ 914e+6
$val(netif1) set L_ 1.0

# Initialize the SharedMedia interface with parameters to make
# it work like the 914MHz Lucent WaveLAN DSSS radio interface
$val(netif2) set CPThresh_ 10.0
$val(netif2) set CSThresh_ 8.91754e-10 ;#sensing range of 200m
$val(netif2) set RXThresh_ 8.91754e-10 ;#communication range of 200m
$val(netif2) set Rb_ 2*1e6
$val(netif2) set Pt_ 0.2818
$val(netif2) set freq_ 914e+6
$val(netif2) set L_ 1.0

# configure the first 5 nodes with transmission range of 500m

$ns node-config -adhocRouting $val(rp) \
-llType $val(ll) \
-macType $val(mac) \
-ifqType $val(ifq) \
-ifqLen $val(ifqlen) \
-antType $val(ant) \
-propType $val(prop) \
-phyType $val(netif1) \
-channelType $val(chan) \
-topoInstance $topo \
-energyModel $val(energymodel) \
-initialEnergy 10 \
-rxPower 0.5 \
-txPower 1.0 \
-idlePower 0.0 \
-sensePower 0.3 \
-agentTrace ON \
-routerTrace ON \
-macTrace OFF \
-movementTrace ON

# Node Creation

set energy(0) 1000

$ns node-config -initialEnergy 1000 \
-rxPower 0.5 \
-txPower 1.0 \
-idlePower 0.0 \
-sensePower 0.3

set node_(0) [$ns node]
$node_(0) color black
set xx [expr rand()*400]
set yy [expr rand()*400]
$node_(0) set X_ $xx 
$node_(0) set Y_ $yy

# configure the remaining 5 nodes with transmission range of 200m

$ns node-config -adhocRouting $val(rp) \
-llType $val(ll) \
-macType $val(mac) \
-ifqType $val(ifq) \
-ifqLen $val(ifqlen) \
-antType $val(ant) \
-propType $val(prop) \
-phyType $val(netif2) \
-channelType $val(chan) \
-topoInstance $topo \
-energyModel $val(energymodel) \
-initialEnergy 10 \
-rxPower 0.5 \
-txPower 1.0 \
-idlePower 0.0 \
-sensePower 0.3 \
-agentTrace ON \
-routerTrace ON \
-macTrace OFF \
-movementTrace ON
for {set i 1} {$i < $val(nn) } {incr i} {

set energy($i) [expr rand()*500]

$ns node-config -initialEnergy $energy($i) \
-rxPower 0.5 \
-txPower 1.0 \
-idlePower 0.0 \
-sensePower 0.3
    set node_($i) [$ns node]
    $node_($i) color black
    set xx [expr rand()*400]
    set yy [expr rand()*400]
    $node_($i) set X_ $xx 
    $node_($i) set Y_ $yy

}

proc finish {} {
    global ns tracefd namtrace
    $ns flush-trace
    close $tracefd
    close $namtrace
    # exec nam wsn.nam &
    exit 0
}

set tcp [new Agent/TCP]
set sink [new Agent/TCPSink]
$tcp set class_ 2

$ns attach-agent $node_(1) $tcp
$ns attach-agent $node_(5) $sink

$ns connect $tcp $sink

set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 0.5 "$ftp start"
$ns at 4.5 "$ftp stop"

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
