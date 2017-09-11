BEGIN {
    udp_packets_recv = 0;
}

$1 == "r" && $2 < now && $4 == toNode && $5 == "cbr" {
    udp_packets_recv++;
};

END {
    udp_throughput = (udp_packets_recv * packet_sz)/(8 * now * 1000000);
    print udp_throughput;
};
