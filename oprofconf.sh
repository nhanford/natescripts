#!/bin/bash

#for debian
#oprofile
codename=$(lsb_release -c | awk  '{print $2}')
if [! -n grep -q ddebs.ubuntu.com /etc/apt/sources.list]
    then
        #sudo tee /etc/apt/sources.list.d/ddebs.list << EOF
        #deb http://ddebs.ubuntu.com/ ${codename}      main restricted universe multiverse
        #deb http://ddebs.ubuntu.com/ ${codename}-security main restricted universe multiverse
        #deb http://ddebs.ubuntu.com/ ${codename}-updates  main restricted universe multiverse
        #deb http://ddebs.ubuntu.com/ ${codename}-proposed main restricted universe multiverse
        #EOF
        echo 'okay'
fi
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ECDCAD72428D7C01
wget http://toolkit.globus.org/ftppub/gt6/installers/repo/globus-toolkit-repo_latest_all.deb
dpkg -i globus-toolkit-repo_latest_all.deb
sudo apt-get update
sudo apt-get install linux-image-$(uname -r)-dbgsym oprofile iperf3 emacs netperf nuttcp flowgrind netpipe --assume-yes
