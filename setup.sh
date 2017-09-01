#!/bin/bash

for i in {0..6}
do
ssh -o StrictHostKeyChecking=no rootnh@192.168.120.19$i << EOF
apt -y install globus-gridftp
EOF
done

#apt -y purge globus-toolkit-repo
#apt -y install python2.7-dev libpython-dev zlib1g-dev apt-transport-https libssl-dev libcurl4-openssl-dev python-dev python-pip
#pip install pycurl
#dpkg -i globus-toolkit-repo_latest_all.deb
#apt update
