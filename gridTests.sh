#!/bin/bash

#kill old pacing stuff, create junk files
for i in 190 191 194 195 196
do
    ssh rootnh@192.168.120.$i << EOF
ifconfig eth1 mtu 9000
tc qdisc add dev eth1 root fq
tc qdisc show dev eth1
openssl rand -out /tmp/rand$i.img -base64 $(( 750 * 406322000000/550229 ))
chmod +r /tmp/rand$i.img
pkill gridftp
pkill iperf3
pkill nuttcp
globus-gridftp-server -S -p 8$i -aa -anonymous-user 'nhanford' -home-dir /
EOF
done

ssh nhanford@192.168.120.192 << EOF 
{ time globus-url-copy -vb ftp://192.168.120.190:8190/tmp/rand190.img file:///tmp/ } > 190Tunpaced.txt &
{ time globus-url-copy -vb ftp://192.168.120.191:8191/tmp/rand191.img file:///tmp/ } > 191Tunpaced.txt &
{ time globus-url-copy -vb ftp://192.168.120.194:8194/tmp/rand194.img file:///tmp/ } > 194Tunpaced.txt &
{ time globus-url-copy -vb ftp://192.168.120.195:8195/tmp/rand195.img file:///tmp/ } > 195Tunpaced.txt &
{ time globus-url-copy -vb ftp://192.168.120.196:8196/tmp/rand196.img file:///tmp/ } > 196Tunpaced.txt
EOF
for j in 190 191 194 195 196
do
	ssh rootnh@192.168.120.$j tc qdisc change dev eth1 root fq maxrate $200Mbit
done
#Sleep processes gridftp
ssh nhanford@192.168.120.192 << EOF 
mkdir -p /tmp
{ time globus-url-copy -vb ftp://192.168.120.190:8190/tmp/rand190.img file:///tmp/ } > 190Tpaced.txt &
{ time globus-url-copy -vb ftp://192.168.120.191:8191/tmp/rand191.img file:///tmp/ } > 191Tpaced.txt &
{ time globus-url-copy -vb ftp://192.168.120.194:8194/tmp/rand194.img file:///tmp/ } > 194Tpaced.txt &
{ time globus-url-copy -vb ftp://192.168.120.195:8195/tmp/rand195.img file:///tmp/ } > 195Tpaced.txt &
{ time globus-url-copy -vb ftp://192.168.120.196:8196/tmp/rand196.img file:///tmp/ } > 196Tpaced.txt 
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
