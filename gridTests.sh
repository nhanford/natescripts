#!/bin/bash

pkill gridftp

mkdir -p /media/gridTmp
mount -t tmpfs -o size=1G tmpfs /media/gridTmp
openssl rand -out /media/gridTmp/rand.img -base64 $(( 750 * 406322000000/550229 ))
chmod +r /media/gridTmp/rand.img

globus-gridftp-server -p -aa -anonymous-user 'nhanford'

#kill old pacing stuff, create junk files
for i in 190 191 194 195 196
do
    ssh rootnh@192.168.120.$i << EOF
ifconfig eth1 mtu 9000
tc qdisc add dev eth1 root fq
tc qdisc show dev eth1
mkdir -p /media/gridTmp
mount -t tmpfs -o size=1G tmpfs /media/gridTmp
openssl rand -out /media/gridTmp/rand.img -base64 $(( 750 * 406322000000/550229 ))
chmod +r /media/gridTmp/rand.img
pkill gridftp
pkill iperf3
pkill nuttcp
globus-gridftp-server -p 8$i -aa -anonymous-user 'nhanford'
EOF
done

ssh nhanford@192.168.120.192 << EOF 
mkdir -p /media/gridTmp
mount -t tmpfs -o size=4G tmpfs /media/gridTmp
globus-url-copy -v 192.168.120.190:2811/media/gridTmp/rand.img /media/gridtmp/rand190.img
globus-url-copy -v 192.168.120.191:2811/media/gridTmp/rand.img /media/gridtmp/rand191.img &
globus-url-copy -v 192.168.120.194:2811/media/gridTmp/rand.img /media/gridtmp/rand194.img &
globus-url-copy -v 192.168.120.195:2811/media/gridTmp/rand.img /media/gridtmp/rand195.img &
globus-url-copy -v 192.168.120.196:2811/media/gridTmp/rand.img /media/gridtmp/rand196.img
EOF
for j in 190 191 194 195 196
do
	ssh rootnh@192.168.120.$j tc qdisc change dev eth1 root fq maxrate $200Mbit
done
#Sleep processes gridftp
ssh nhanford@192.168.120.192 << EOF 
mkdir -p /media/gridTmp
mount -t tmpfs -o size=4G tmpfs /media/gridTmp
globus-url-copy -v 192.168.120.190:2811/media/gridTmp/rand.img /media/gridtmp/rand190.img &
globus-url-copy -v 192.168.120.191:2811/media/gridTmp/rand.img /media/gridtmp/rand191.img &
globus-url-copy -v 192.168.120.194:2811/media/gridTmp/rand.img /media/gridtmp/rand194.img &
globus-url-copy -v 192.168.120.195:2811/media/gridTmp/rand.img /media/gridtmp/rand195.img &
globus-url-copy -v 192.168.120.196:2811/media/gridTmp/rand.img /media/gridtmp/rand196.img 
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

scp -r nhanford@192.168.120.192 ~/$d ./
