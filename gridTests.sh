#!/bin/bash

#kill old pacing stuff, create junk files
for i in 190 191 194 195 196
do
    ssh rootnh@192.168.120.$i << EOF
ifconfig eth1 mtu 9000
tc qdisc add dev eth1 root fq
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
{ time globus-url-copy -vb ftp://192.168.120.190:8190/tmp/zero190.img file:///dev/null ;} 2> 190Tunpaced.txt &
{ time globus-url-copy -vb ftp://192.168.120.191:8191/tmp/zero191.img file:///dev/null ;} 2> 191Tunpaced.txt &
{ time globus-url-copy -vb ftp://192.168.120.194:8194/tmp/zero194.img file:///dev/null ;} 2> 194Tunpaced.txt &
{ time globus-url-copy -vb ftp://192.168.120.195:8195/tmp/zero195.img file:///dev/null ;} 2> 195Tunpaced.txt &
{ time globus-url-copy -vb ftp://192.168.120.196:8196/tmp/zero196.img file:///dev/null ;} 2> 196Tunpaced.txt
EOF
for j in 190 191 194 195 196
do
	ssh rootnh@192.168.120.$j << EOF 
tc qdisc change dev eth1 root fq maxrate $200Mbit
tc qdisc show dev eth1
EOF
done
#Sleep processes gridftp
ssh nhanford@192.168.120.192 << EOF 
mkdir -p /tmp
{ time globus-url-copy -vb ftp://192.168.120.190:8190/tmp/zero190.img file:///dev/null ;} 2> 190Tpaced.txt &
{ time globus-url-copy -vb ftp://192.168.120.191:8191/tmp/zero191.img file:///dev/null ;} 2> 191Tpaced.txt &
{ time globus-url-copy -vb ftp://192.168.120.194:8194/tmp/zero194.img file:///dev/null ;} 2> 194Tpaced.txt &
{ time globus-url-copy -vb ftp://192.168.120.195:8195/tmp/zero195.img file:///dev/null ;} 2> 195Tpaced.txt &
{ time globus-url-copy -vb ftp://192.168.120.196:8196/tmp/zero196.img file:///dev/null ;} 2> 196Tpaced.txt 
EOF
for i in 190 191 194 195 196
do
    ssh rootnh@192.168.120.$i tc qdisc del dev eth1 root
done

d=$(date +%F-%H-%M)

ssh nhanford@192.168.120.192 << EOF
mkdir ~/$d
mv *.txt ~/$d
EOF

scp -r nhanford@192.168.120.192:~/$d ./

# Just send 0's from source
# destination is /dev/null
# ask Raj how to restrict to a single flow
