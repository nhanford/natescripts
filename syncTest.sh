#!/bin/bash

# To be run from 192.168.120.193

ssh nhanford@192.168.120.192 << EOF
iperf3 -sDp 5200
iperf3 -sDp 5201
EOF

# Remove any remnants of pacing
for i in 192.168.120.190 192.168.120.191
do
    ssh rootnh@$i ifconfig eth1 mtu 9000
done

i=htcp
ssh rootnh@192.168.120.190 tc qdisc del dev eth1 root
ssh rootnh@192.168.120.191 tc qdisc del dev eth1 root

# 2 TCP unpaced, grabbing for max
ssh nhanford@192.168.120.190 iperf3 -i.1 -VJc 192.168.100.192 -p 5200 -t45 --logfile $i-T-T-190.json &
ssh nhanford@192.168.120.191 iperf3 -i.1 -VJc 192.168.100.192 -p 5201 -t45 --logfile $i-T-T-191.json 
sleep 3

# 1 TCP unpaced, competing with a UDP paced to 1G, grabbing for max
ssh nhanford@192.168.120.190 iperf3 -i.1 -VJc 192.168.100.192 -p 5200 -t45 --logfile htcp-T-U-190.json &
ssh nhanford@192.168.120.191 iperf3 -i.1 -VJuc 192.168.100.192 -b 1Gbit -p 5201 -t45 --logfile htcp-U-T-191.json
sleep 3

# 1 TCP unpaced, competing with a repeating bursty set of mouse flows
ssh nhanford@192.168.120.190 iperf3 -i.1 -VJc 192.168.100.192 -p 5200 -t45 --logfile htcp-T-U-190.json &
for i in {1..14}
do
    ssh nhanford@192.168.120.191 iperf3 -i.1 -VJuc 192.168.100.192 -b 1Gbit -p 5201 -t1 --logfile htcp-U-T-191.json
    sleep 3
done

# 2 TCP paced to 400M
ssh rootnh@192.168.120.190 tc qdisc add dev eth1 root fq maxrate 400Mbit
ssh rootnh@192.168.120.191 tc qdisc add dev eth1 root fq maxrate 400Mbit
ssh nhanford@192.168.120.190 iperf3 -i.1 -VJc 192.168.100.192 -p 5200 -t45 --logfile $i-T400M-400M-190.json &
ssh nhanford@192.168.120.191 iperf3 -i.1 -VJc 192.168.100.192 -p 5201 -t45 --logfile $i-T400M-400M-191.json 
sleep 3

# 2 TCP paced to 500M
ssh rootnh@192.168.120.190 tc qdisc change dev eth1 root fq maxrate 500Mbit
ssh rootnh@192.168.120.191 tc qdisc change dev eth1 root fq maxrate 500Mbit
ssh nhanford@192.168.120.190 iperf3 -i.1 -VJc 192.168.100.192 -p 5200 -t45 --logfile $i-T500M-500M-190.json &
ssh nhanford@192.168.120.191 iperf3 -i.1 -VJc 192.168.100.192 -p 5201 -t45 --logfile $i-T500M-500M-191.json 
sleep 3

# 2 TCP paced to 600M
ssh rootnh@192.168.120.190 tc qdisc change dev eth1 root fq maxrate 600Mbit
ssh rootnh@192.168.120.191 tc qdisc change dev eth1 root fq maxrate 600Mbit
ssh nhanford@192.168.120.190 iperf3 -i.1 -VJc 192.168.100.192 -p 5200 -t45 --logfile $i-T600M-600M-190.json &
ssh nhanford@192.168.120.191 iperf3 -i.1 -VJc 192.168.100.192 -p 5201 -t45 --logfile $i-T600M-600M-191.json 
sleep 3

# 1 TCP paced to 800M, 1 TCP paced to 100M
ssh rootnh@192.168.120.190 tc qdisc change dev eth1 root fq maxrate 800Mbit
ssh rootnh@192.168.120.191 tc qdisc change dev eth1 root fq maxrate 100Mbit
ssh nhanford@192.168.120.190 iperf3 -i.1 -VJc 192.168.100.192 -p 5200 -t45 --logfile $i-T800M-100M-190.json &
ssh nhanford@192.168.120.191 iperf3 -i.1 -VJc 192.168.100.192 -p 5201 -t45 --logfile $i-T100M-800M-191.json 
sleep 3

# 1 TCP paced to 900M, 1 TCP paced to 100M
ssh rootnh@192.168.120.190 tc qdisc change dev eth1 root fq maxrate 900Mbit
ssh nhanford@192.168.120.190 iperf3 -i.1 -VJc 192.168.100.192 -p 5200 -t45 --logfile $i-T900M-100M-190.json &
ssh nhanford@192.168.120.191 iperf3 -i.1 -VJc 192.168.100.192 -p 5201 -t45 --logfile $i-T100M-900M-191.json
sleep 3

d=$(date +%F-%H-%M)
mkdir ~/$d
scp nhanford@192.168.120.190:~/*.json ~/$d
scp nhanford@192.168.120.191:~/*.json ~/$d

ssh nhanford@192.168.120.190 rm *.json
ssh nhanford@192.168.120.191 rm *.json
