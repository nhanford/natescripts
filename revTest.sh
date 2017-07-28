#!/bin/bash

#kill old pacing stuff
for i in 192.168.120.190 192.168.120.191
do
    ssh rootnh@$i << EOF
ifconfig eth1 mtu 9000
tc qdisc add dev eth1 root fq
tc qdisc show dev eth1
EOF
done

for i in 192.168.120.190 192.168.120.191
do
    ssh nhanford@$i nuttcp -S
done

for i in {1..10}
do
    for j in 192.168.120.190 192.168.120.191
    do
        ssh rootnh@$j tc qdisc change dev eth1 root fq maxrate ${i}00Mbit
    done
    #Sleep processes nuttcp
    ssh nhanford@192.168.120.192 << EOF 
nuttcp -v -r -p8190 -T60 -i.1 -fparse 192.168.100.190 > T${i}00-T${i}00-190.txt &
nuttcp -v -r -p8191 -T60 -i.1 -fparse 192.168.100.191 > T${i}00-T${i}00-191.txt
EOF
done

d=$(date +%F-%H-%M)
mkdir ~/$d
scp nhanford@192.168.120.192:~/*.txt ~/$d
ssh nhanford@192.168.120.192 rm *.txt

for i in 192.168.120.190 192.168.120.191
do
    ssh rootnh@$i tc qdisc del dev eth1 root
done
