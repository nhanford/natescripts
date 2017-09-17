#!/bin/bash

# create junk files, start servers
for i in 190 191 194 
do
	echo "*******First contact to $i"
    ssh rootnh@192.168.120.$i << EOF
ifconfig eth1 mtu 9000
tc qdisc add dev eth1 root fq maxrate 330Mbit
tc qdisc show dev eth1
if [ ! -e "/storage/zero.img" ]
then
	dd if=/dev/zero of=/storage/zero.img bs=1M count=10240
	chmod +r /storage/zero.img
fi
ls /storage | grep img
globus-gridftp-server -S -p 8$i -data-interface 192.168.100.$i -aa -anonymous-user 'nhanford' -home-dir / -Z ~/$i.log -log-level all
ps aux | grep gridftp
EOF
done

echo "*******First contact to 201"
ssh rootnh@192.168.120.201 << EOF
ifconfig eth1 mtu 9000
tc qdisc add dev eth1 root fq maxrate 330Mbit
tc qdisc show dev eth1
if [ ! -e "/storage/zero.img" ]
then
	dd if=/dev/zero of=/storage/zero.img bs=1M count=10240
	chmod +r /storage/zero.img
fi
ls /storage | grep img
globus-gridftp-server -S -p 8195 -data-interface 192.168.100.195 -aa -anonymous-user 'nhanford' -home-dir / -Z ~/201.log -log-level all
ps aux | grep gridftp
EOF

echo "*******Contacting receiving server"

#scp alias-file xfer-file rootnh@192.168.120.192:~

ssh rootnh@192.168.120.192 << EOF
ifconfig eth1 mtu 9000
globus-gridftp-server -S -p 8192 -data-interface 192.168.100.192 -aa -anonymous-user 'nhanford' -home-dir / -Z ~/192.log -log-level all
ps aux | grep gridftp
EOF

time globus-url-copy -cc 3 -p 1 -af alias-file -f xfer-file

sleep 10

for i in 190 191 194 201 
do
	echo "********Second contact to $i"
	ssh rootnh@192.168.120.$i << EOF 
tc qdisc del dev eth1 root
tc qdisc show dev eth1
EOF
done

time globus-url-copy -cc 3 -p 1 -af alias-file -f xfer-file

sleep 10

d=$(date +%F-%H-%M)
mkdir ~/$d

# move logs, stop servers
for i in 190 191 192 194 201 
do
	echo "********Third contact to $i"
	scp rootnh@192.168.120.$i:~/$i.log ~/$d
	ssh rootnh@192.168.120.$i << EOF
mkdir ~/$d
mv *.log ~/$d
pkill gridftp
ps aux | grep gridftp
EOF
done
