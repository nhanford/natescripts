#!/bin/bash
for i in {1..10}
do
   iperf3 -c 10.12.1.20 -O 5 -t 30 -w 250M -Z | tee -a local-40-40-pon-pc-1500B.txt
done
