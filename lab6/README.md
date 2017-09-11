##### If you find any bug, please feel free to raise an issue. I'll be happy to fix it. Or you can give a PR yourself :)

+ Run `ns tcp_linear.tcl <QType>` where `QType` can be `DropTail`, `RED` or `SFQ`
+ Run `xgraph -bar -brw 0.1 tcp-throughput.tr` to get a plot of throughput
+ Run `xgraph -bar -brw 0.1 tcp-packetloss.tr` to get a plot of packetloss

---

+ Run `ns udp_linear.tcl <QType>` where `QType` can be `DropTail`, `RED` or `SFQ`
+ Run `xgraph -bar -brw 0.1 udp-throughput.tr` to get a plot of throughput
+ Run `xgraph -bar -brw 0.1 udp-packetloss.tr` to get a plot of packetloss

---

+ Run `ns combined_linear.tcl <QType>` where `QType` can be `DropTail`, `RED` or `SFQ`
+ Run `xgraph -bar -brw 0.1 combined-throughput.tr` to get a plot of throughput
+ Run `xgraph -bar -brw 0.1 combined-packetloss.tr` to get a plot of packetloss

---

+ In case you want consolidated graphs i.e. one for throughput and one for packet-loss, do the following
+ comment out the line `exec nam <filename>.nam &` in the `finish` procedures in the three `tcl` files
```
bash generate_throughput.sh
```
```
bash generate_packetloss.sh
```
