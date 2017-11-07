#!/bin/bash

# 201 is now the receiver, 192 is a sender, 193 is still the controller

#kill old pacing stuff, create junk files
for i in 190 191 192 194 200 201
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
globus-gridftp-server -S -p 8$i -aa -anonymous-user 'nhanford' -home-dir /
EOF
done

ssh nhanford@192.168.120.192 << EOF 
mkdir -p /tmp
{ time globus-url-copy -p 1 ftp://192.168.100.190:8190/tmp/zero190.img file:///dev/null ;} 2> 190Tpaced.txt &
{ time globus-url-copy -p 1 ftp://192.168.100.191:8191/tmp/zero191.img file:///dev/null ;} 2> 191Tpaced.txt &
{ time globus-url-copy -p 1 ftp://192.168.100.194:8194/tmp/zero194.img file:///dev/null ;} 2> 194Tpaced.txt &
{ time globus-url-copy -p 1 ftp://192.168.100.200:8200/tmp/zero200.img file:///dev/null ;} 2> 200Tpaced.txt &
{ time globus-url-copy -p 1 ftp://192.168.100.201:8201/tmp/zero201.img file:///dev/null ;} 2> 201Tpaced.txt 
sleep 180
EOF

for j in 190 191 194 200 201
do
	ssh rootnh@192.168.120.$j << EOF 
tc qdisc del dev eth1 root
tc qdisc show dev eth1
EOF
done

ssh nhanford@192.168.120.192 << EOF 
{ time globus-url-copy -p 1 ftp://192.168.100.190:8190/tmp/zero190.img file:///dev/null ;} 2> 190Tunpaced.txt &
{ time globus-url-copy -p 1 ftp://192.168.100.191:8191/tmp/zero191.img file:///dev/null ;} 2> 191Tunpaced.txt &
{ time globus-url-copy -p 1 ftp://192.168.100.194:8194/tmp/zero194.img file:///dev/null ;} 2> 194Tunpaced.txt &
{ time globus-url-copy -p 1 ftp://192.168.100.200:8200/tmp/zero200.img file:///dev/null ;} 2> 200Tunpaced.txt &
{ time globus-url-copy -p 1 ftp://192.168.100.201:8201/tmp/zero201.img file:///dev/null ;} 2> 201Tunpaced.txt
sleep 180
EOF

d=$(date +%F-%H-%M)

ssh nhanford@192.168.120.192 << EOF
mkdir ~/$d
mv *.txt ~/$d
EOF

scp -r nhanford@192.168.120.192:~/$d ./
