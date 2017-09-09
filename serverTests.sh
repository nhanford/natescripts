#!/bin/bash

#create junk files, refresh servers
for i in 190 191 194 195 196
do
    ssh rootnh@192.168.120.$i << EOF
ifconfig eth1 mtu 9000
tc qdisc add dev eth1 root fq maxrate 200Mbit
tc qdisc show dev eth1
if [ ! -e "/tmp/zero$i.img" ]
then
	dd if=/dev/zero of=/tmp/zero$i.img bs=1M count=4096
	chmod +r /tmp/zero$i.img
fi
pkill gridftp
pkill iperf3
pkill nuttcp
# server -z and then logpath
globus-gridftp-server -S -p 8$i -aa -anonymous-user 'nhanford' -home-dir /
EOF
done

d=$(date +%F-%H-%M)

globus-url-copy -cc 5 -p 1 -af alias-file -f xfer-file -z ~/paced$d.log
sleep 180

for j in 190 191 194 195 196
do
	ssh rootnh@192.168.120.$j << EOF 
tc qdisc del dev eth1 root
tc qdisc show dev eth1
EOF
done

globus-url-copy -cc 5 -p 1 -af alias-file -f xfer-file -z ~/paced$d.log
