#!/bin/bash
# to be run from controller (193)

# create junk files, start servers
for i in 190 191 192 194 200
do
	echo "*******First contact to $i"
    ssh rootnh@192.168.120.$i << EOF
ifconfig eth1 mtu 9000
tc qdisc del dev eth1 root
tc qdisc show dev eth1
if [ ! -e "/storage/zero.img" ]
then
	dd if=/dev/zero of=/storage/zero.img bs=1M count=5120
	chmod +r /storage/zero.img
fi
ls /storage | grep img
globus-gridftp-server -S -p 8$i -data-interface 192.168.100.$i -aa -anonymous-user 'nhanford' -home-dir / -Z ~/$i.log -log-level all
ps aux | grep gridftp
EOF
done

echo "*******Contacting receiving server"

scp alias-file xfer-file rootnh@192.168.120.201:~

ssh rootnh@192.168.120.201 << EOF
ifconfig eth1 mtu 9000
globus-gridftp-server -S -p 8201 -data-interface 192.168.100.201 -aa -anonymous-user 'nhanford' -home-dir / -Z ~/201.log -log-level all
ps aux | grep gridftp
EOF

time globus-url-copy -cc 5 -p 1 -af alias-file -f xfer-file

d=$(date +%F-%H-%M)
mkdir ~/$d

# move logs, stop servers
for i in 190 191 192 201 
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

cp results.py ~/$d
cd ~/$d
./results.py
