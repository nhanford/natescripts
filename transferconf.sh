#!/bin/bash

for i in 192.168.120.190 192.168.120.191
do
    ssh rootnh@$i << EOF
ifconfig eth1 mtu 9000
tc qdisc add dev eth1 root fq
tc qdisc show dev eth1
tc qdisc del dev eth1 root
tc qdisc show dev eth1
EOF
done
