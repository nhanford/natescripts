#!/bin/bash

#Nathan Hanford nhanford@es.net
#Portions borrowed from everywhere.
read -p "To be run on a fresh CentOS installation\nWant to remove bloatware? " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    echo "Insert the yum remove here once you have a working CentOS image."
fi
#Change to appropriate CentOS repo name
codename=$(lsb_release -c | awk  '{print $2}')
#Re-do for debuginfo file
#ADD EPEL REPO
if ! [-a /etc/yum.repos.d/CentOS-Debuginfo.repo]
then
sudo tee /etc/yum.repos.d/CentOS-Debuginfo.repo << EOF

EOF
fi
#should be able to install globus rpm from epel repo
#yum update this is how you screw yourself
yum install kernel-debuginfo oprofile iperf3 emacs netperf nuttcp flowgrind systemtap

