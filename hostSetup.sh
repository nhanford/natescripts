#!/bin/bash

chsh rootnh -s /bin/bash
chsh nhanford -s /bin/bash

apt purge iperf3 libiperf0 nuttcp

wget -O /etc/apt/sources.list.d/perfsonar-jessie-4.0.list http://downloads.perfsonar.net/debian/perfsonar-jessie-4.0.list
wget -qO - http://downloads.perfsonar.net/debian/perfsonar-debian-official.gpg.key | apt-key add -

apt update

apt install git perfsonar-tools

git clone git@github.com:nhanford/natescripts.git
