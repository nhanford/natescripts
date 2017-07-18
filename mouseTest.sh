#!/bin/bash

# To be run from 192.168.120.193

ssh nhanford@192.168.120.192 << EOF
iperf3 -sDp 5200
iperf3 -sDp 5201
EOF

# Remove any remnants of pacing
for i in 192.168.120.190 192.168.120.191
do
    ssh rootnh@$i << EOF 
ifconfig eth1 mtu 9000
tc qdisc del dev eth1 root
EOF
done

# 1 TCP unpaced, competing with a repeating bursty set of mouse flows
ssh nhanford@192.168.120.190 iperf3 -i.1 -VJc 192.168.100.192 -p 5200 -t600 --logfile htcp-T-U-190.json &
for i in {1..200}
do
    ssh nhanford@192.168.120.191 iperf3 -i.1 -uc 192.168.100.192 -b 1Gbit -p 5201 -t1
    sleep 3
done

# 1 TCP paced, competing with a repeating bursty set of mouse flows
ssh rootnh@192.168.120.190 tc qdisc add dev eth1 root fq maxrate 1Gbit
ssh nhanford@192.168.120.190 iperf3 -i.1 -VJc 192.168.100.192 -p 5200 -t600 --logfile htcp-T1000-U-190.json &
for i in {1..200}
do
    ssh nhanford@192.168.120.191 iperf3 -i.1 -uc 192.168.100.192 -b 1Gbit -p 5201 -t1
    sleep 3
done

# 1 TCP paced, competing with a repeating bursty set of mouse flows
ssh rootnh@192.168.120.190 tc qdisc change dev eth1 root fq maxrate 900Mbit
ssh nhanford@192.168.120.190 iperf3 -i.1 -VJc 192.168.100.192 -p 5200 -t600 --logfile htcp-T900-U-190.json &
for i in {1..200}
do
    ssh nhanford@192.168.120.191 iperf3 -i.1 -uc 192.168.100.192 -b 1Gbit -p 5201 -t1
    sleep 3
done

# 1 TCP paced, competing with a repeating bursty set of mouse flows
ssh rootnh@192.168.120.190 tc qdisc change dev eth1 root fq maxrate 500Mbit
ssh nhanford@192.168.120.190 iperf3 -i.1 -VJc 192.168.100.192 -p 5200 -t600 --logfile htcp-T500-U-190.json &
for i in {1..200}
do
    ssh nhanford@192.168.120.191 iperf3 -i.1 -uc 192.168.100.192 -b 1Gbit -p 5201 -t1
    sleep 3
done

d=$(date +%F-%H-%M)
mkdir ~/$d
scp nhanford@192.168.120.190:~/*.json ~/$d

ssh nhanford@192.168.120.190 rm *.json
