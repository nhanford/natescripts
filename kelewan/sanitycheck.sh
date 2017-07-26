#!/bin/bash

sudo cpupower -c all frequency-set -g userspace
sudo cpupower -c all frequency-set -f 3.5G

#kill old pacing stuff
sudo tc qdisc add dev eth3 root fq

for i in {1..10}
do
    ssh rootnh@$j tc qdisc change dev eth1 root fq maxrate ${i}Gbit
    bwctl -pvi.1 -t60 --parsable -c atla-pt1.es.net
    mv *.bw atla-${i}.json
    rm *.bw
done

sudo tc qdisc del dev eth3 root

bwctl -pvi.1 -t60 --parsable -c atla-pt1.es.net
mv *.bw atla-unpaced.json
rm *.bw

d=$(date +%F-%H-%M)
mkdir ~/$d
mv *.json ~/$d

sudo cpupower -c all frequency-set -f 1.2G
