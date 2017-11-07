#!/bin/bash

#kill old pacing stuff
# 201 is now the receiver
for i in 190 191 192 194 200 201
do
    ssh rootnh@192.168.120.$i << EOF
ifconfig eth1 mtu 9000
tc del add dev eth1 root
tc qdisc show dev eth1
EOF
done

for i in 190 191 192 194 200
do
    ssh nhanford@192.168.120.$i << EOF 
nuttcp -S -P 5$i
iperf3 -sD
EOF
done

for i in {1..3}
do
    #Sleep processes nuttcp
    ssh nhanford@192.168.120.201 << EOF 
nuttcp -v -P5190 -p8190 -T30 -i.1 -fparse 192.168.100.190 > unpaced-190.txt &
nuttcp -v -P5191 -p8191 -T30 -i.1 -fparse 192.168.100.191 > unpaced-191.txt &
nuttcp -v -P5194 -p8194 -T30 -i.1 -fparse 192.168.100.194 > unpaced-194.txt &
nuttcp -v -P5200 -p8200 -T30 -i.1 -fparse 192.168.100.200 > unpaced-200.txt &
nuttcp -v -P5201 -p8201 -T30 -i.1 -fparse 192.168.100.192 > unpaced-192.txt 
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

