#!/bin/bash

ssh nhanford@192.168.120.192 nuttcp -S

#kill old pacing stuff
for i in 192.168.120.190 192.168.120.191
do
    ssh rootnh@$i << EOF
ifconfig eth1 mtu 9000
tc qdisc del dev eth1 root
tc qdisc add dev eth1 root fq
tc qdisc show dev eth1
EOF
done

for i in {1..10}
do
    for j in 192.168.120.190 192.168.120.191
    do
        ssh rootnh@$j tc qdisc change dev eth1 root fq maxrate ${i}00Mbit
    done
    #Sleep processes nuttcp
    ssh nhanford@192.168.120.191 nuttcp -vv -T45 -i.1 -fparse 192.168.120.192 | tee T${i}00-T${i}00-191.txt
    #Final wait
done

d=$(date +%F-%H-%M)
mkdir ~/$d
scp nhanford@192.168.120.190:~/*.txt ~/$d
scp nhanford@192.168.120.191:~/*.txt ~/$d
mv *.txt ~/$d

ssh nhanford@192.168.120.190 rm *.txt
ssh nhanford@192.168.120.191 rm *.txt

for i in 192.168.120.190 192.168.120.191
do
    ssh rootnh@$i tc qdisc del dev eth1 root
done
