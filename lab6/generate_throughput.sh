rm -rf throughput_tcp.xg throughput_udp.xg throughput_com.xg

ns tcp_linear.tcl DropTail
awk -v x=1.0 -f throughput.awk tcp.tr >> throughput_tcp.xg
ns tcp_linear.tcl RED
awk -v x=3.0 -f throughput.awk tcp.tr >> throughput_tcp.xg
ns tcp_linear.tcl SFQ
awk -v x=5.0 -f throughput.awk tcp.tr >> throughput_tcp.xg
ns udp_linear.tcl DropTail
awk -v x=1.3 -f throughput.awk udp.tr >> throughput_udp.xg
ns udp_linear.tcl RED
awk -v x=3.3 -f throughput.awk udp.tr >> throughput_udp.xg
ns udp_linear.tcl SFQ
awk -v x=5.3 -f throughput.awk udp.tr >> throughput_udp.xg
ns combined_linear.tcl DropTail
awk -v x=1.5 -f throughput.awk combined.tr >> throughput_com.xg
ns combined_linear.tcl RED
awk -v x=3.5 -f throughput.awk combined.tr >> throughput_com.xg
ns combined_linear.tcl SFQ
awk -v x=5.5 -f throughput.awk combined.tr >> throughput_com.xg
xgraph -bar -brw 0.1 throughput_tcp.xg throughput_udp.xg throughput_com.xg