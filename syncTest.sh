#!/bin/bash

# To be run from 192.168.120.193

PORT = 5200

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

for i in htcp reno cubic
do

    # 2 TCP unpaced, grabbing for max
    ssh nhanford@192.168.120.190 iperf3 -VJc 192.168.100.192 -p 5200 -t45 --logfile T-T-unpaced190.json &
    ssh nhanford@192.168.120.191 iperf3 -VJc 192.168.100.192 -p 5201 -t45 --logfile T-T-unpaced191.json 
    
    # 1 TCP unpaced, competing with a UDP paced to 1G, grabbing for max
    ssh nhanford@192.168.120.190 iperf3 -VJc 192.168.100.192 -p 5200 -t45 --logfile T-U-unpaced190.json &
    ssh nhanford@192.168.120.191 iperf3 -VJuc 192.168.100.192 -p 5201 -t45 --logfile T-U-unpaced191.json

    # 2 TCP paced to 400M
    ssh rootnh@192.168.120.190 tc qdisc add dev eth1 root fq maxrate 400Mbit
    ssh rootnh@192.168.120.191 tc qdisc add dev eth1 root fq maxrate 400Mbit
    ssh nhanford@192.168.120.190 iperf3 -VJc 192.168.100.192 -p 5200 -t45 --logfile T400M-400M-190.json &
    ssh nhanford@192.168.120.191 iperf3 -VJc 192.168.100.192 -p 5201 -t45 --logfile T400M-400M-191.json 

    # 2 TCP paced to 500M
    ssh rootnh@192.168.120.190 tc qdisc change dev eth1 root fq maxrate 500Mbit
    ssh rootnh@192.168.120.191 tc qdisc change dev eth1 root fq maxrate 500Mbit
    ssh nhanford@192.168.120.190 iperf3 -VJc 192.168.100.192 -p 5200 -t45 --logfile T500M-500M-190.json &
    ssh nhanford@192.168.120.191 iperf3 -VJc 192.168.100.192 -p 5201 -t45 --logfile T500M-500M-191.json 
    
    # 1 TCP paced to 800M, 1 TCP paced to 100M
    ssh rootnh@192.168.120.190 tc qdisc change dev eth1 root fq maxrate 800Mbit
    ssh rootnh@192.168.120.191 tc qdisc change dev eth1 root fq maxrate 100Mbit
    ssh nhanford@192.168.120.190 iperf3 -VJc 192.168.100.192 -p 5200 -t45 --logfile T800M-100M-190.json &
    ssh nhanford@192.168.120.191 iperf3 -VJc 192.168.100.192 -p 5201 -t45 --logfile T100M-800M-191.json 
    
    # 1 TCP paced to 900M, 1 TCP paced to 100M
    ssh rootnh@192.168.120.190 tc qdisc change dev eth1 root fq maxrate 900Mbit
    ssh nhanford@192.168.120.190 iperf3 -VJc 192.168.100.192 -p 5200 -t45 --logfile T900M-100M-190.json &
    ssh nhanford@192.168.120.191 iperf3 -VJc 192.168.100.192 -p 5201 -t45 --logfile T100M-900M-191.json
done
