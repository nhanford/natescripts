#!/bin/bash

# create junk files, start servers
for i in 190 191 194 195 196
do
	echo "First contact to $i"
    ssh rootnh@192.168.120.$i << EOF
ifconfig eth1 mtu 9000
tc qdisc add dev eth1 root fq maxrate 200Mbit
tc qdisc show dev eth1
if [ ! -e "/tmp/zero.img" ]
then
	dd if=/dev/zero of=/tmp/zero.img bs=1M count=4096
	chmod +r /tmp/zero.img
fi
ls /tmp | grep img
globus-gridftp-server -S -p 8$i -aa -anonymous-user 'nhanford' -home-dir / -Z ~/$i.log -log-level all
ps aux | grep gridftp
EOF
done

echo "attempting contact to receiving server"
ssh rootnh@192.168.120.192 << EOF
ifconfig eth1 mtu 9000
globus-gridftp-server -S -p 8192 -aa -anonymous-user 'nhanford' -home-dir / -Z ~/192.log -log-level all
ps aux | grep gridftp
EOF

globus-url-copy -cc 5 -p 1 -af alias-file -f xfer-file
sleep 10

for i in 190 191 194 195 196
do
	echo "second contac to $i"
	ssh rootnh@192.168.120.$i << EOF 
tc qdisc del dev eth1 root
tc qdisc show dev eth1
EOF
done

globus-url-copy -cc 5 -p 1 -af alias-file -f xfer-file
sleep 10

d=$(date +%F-%H-%M)
mkdir ~/$d

# move logs, stop servers
for i in 190 191 192 194 195 196
do
	echo "third contact to $i"
	scp rootnh@192.168.120.$i:~/$i.log ~/$d
	ssh rootnh@192.168.120.$i << EOF
mkdir ~/$d
mv *.log ~/$d
pkill gridftp
ps aux | grep gridftp
EOF
done
