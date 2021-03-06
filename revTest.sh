#!/bin/bash

#kill old pacing stuff
for i in 190 191 194 200 201
do
    ssh rootnh@192.168.120.$i << EOF
ifconfig eth1 mtu 9000
tc qdisc add dev eth1 root fq
tc qdisc show dev eth1
EOF
done

for i in 190 191 194 200 201
do
    ssh nhanford@192.168.120.$i << EOF 
nuttcp -S -P 5$i
iperf3 -sD
EOF
done

for i in {1..10}
do
    for j in 190 191 194 200 201
    do
        ssh rootnh@192.168.120.$j tc qdisc change dev eth1 root fq maxrate ${i}00Mbit
    done
    #Sleep processes nuttcp
    ssh nhanford@192.168.120.192 << EOF 
nuttcp -v -r -R${i}00M -P5190 -p8190 -T30 -i.1 -fparse 192.168.100.190 > T${i}00-190.txt &
nuttcp -v -r -R${i}00M -P5191 -p8191 -T30 -i.1 -fparse 192.168.100.191 > T${i}00-191.txt &
nuttcp -v -r -R${i}00M -P5194 -p8194 -T30 -i.1 -fparse 192.168.100.194 > T${i}00-194.txt &
nuttcp -v -r -R${i}00M -P5200 -p8200 -T30 -i.1 -fparse 192.168.100.200 > T${i}00-200.txt &
nuttcp -v -r -R${i}00M -P5201 -p8201 -T30 -i.1 -fparse 192.168.100.201 > T${i}00-201.txt 
sleep 30
EOF
done

for i in 190 191 194 200 201
do
    ssh rootnh@192.168.120.$i tc qdisc del dev eth1 root
done

d=$(date +%F-%H-%M)

ssh nhanford@192.168.120.192 << EOF
mkdir ~/$d
mv *.txt ~/$d
EOF

scp -r nhanford@192.168.120.192:~/$d ./
