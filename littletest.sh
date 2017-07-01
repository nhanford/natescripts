#!/bin/bash
for i in {1..10}
do
   iperf3 -c 10.120.1.55 -O 23 -t 30 -w 512M -Z | tee -a loop-40-10-pon-nopc-9000B.txt
done
