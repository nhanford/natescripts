#!/bin/bash


ssh nhanford@192.168.120.190 iperf3 -i.1 -Vc 192.168.100.192 -p 5200 -t45 &
ssh nhanford@192.168.120.191 iperf3 -i.1 -Vuc 192.168.100.192 -p 5201 -b 1Gbit -t45
