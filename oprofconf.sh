#!/bin/bash

#globus


#for debian
#oprofile
codename=$(lsb_release -c | awk  '{print $2}')
if grep -q ddebs.ubuntu.com :
sudo tee /etc/apt/sources.list.d/ddebs.list << EOF
deb http://ddebs.ubuntu.com/ ${codename}      main restricted universe multiverse
deb http://ddebs.ubuntu.com/ ${codename}-security main restricted universe multiverse
deb http://ddebs.ubuntu.com/ ${codename}-updates  main restricted universe multiverse
deb http://ddebs.ubuntu.com/ ${codename}-proposed main restricted universe multiverse
EOF
fi
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ECDCAD72428D7C01
wget 
sudo apt-get update
sudo apt-get install linux-image-$(uname -r)-dbgsym oprofile iperf3 emacs netperf nuttcp flowgrind netpipe --assume-yes
