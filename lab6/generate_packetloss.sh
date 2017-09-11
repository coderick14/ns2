rm -rf packet_loss_tcp.xg packet_loss_udp.xg packet_loss_com.xg

ns tcp_linear.tcl DropTail
awk -v x=1.0 -f packetloss_total.awk tcp.tr >> packet_loss_tcp.xg
ns tcp_linear.tcl RED
awk -v x=3.0 -f packetloss_total.awk tcp.tr >> packet_loss_tcp.xg
ns tcp_linear.tcl SFQ
awk -v x=5.0 -f packetloss_total.awk tcp.tr >> packet_loss_tcp.xg
ns udp_linear.tcl DropTail
awk -v x=1.3 -f packetloss_total.awk udp.tr >> packet_loss_udp.xg
ns udp_linear.tcl RED
awk -v x=3.3 -f packetloss_total.awk udp.tr >> packet_loss_udp.xg
ns udp_linear.tcl SFQ
awk -v x=5.3 -f packetloss_total.awk udp.tr >> packet_loss_udp.xg
ns combined_linear.tcl DropTail
awk -v x=1.5 -f packetloss_total.awk combined.tr >> packet_loss_com.xg
ns combined_linear.tcl RED
awk -v x=3.5 -f packetloss_total.awk combined.tr >> packet_loss_com.xg
ns combined_linear.tcl SFQ
awk -v x=5.5 -f packetloss_total.awk combined.tr >> packet_loss_com.xg
xgraph -bar -brw 0.1 packet_loss_tcp.xg packet_loss_udp.xg packet_loss_com.xg
