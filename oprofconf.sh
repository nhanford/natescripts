#!/bin/bash

#Nathan Hanford nhanford@es.net
#Portions borrowed from everywhere.
read -p "To be run on a fresh Ubuntu installation\nWant to remove bloatware? " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    sudo apt-get remove deja-dup gnome-contacts gnome-mines aisleriot gnome-sudoku gnome-mahjongg libreoffice-draw unity-lens-photos shotwell-common remmina thunderbird empathy transmission-gtk libreoffice-math libreoffice-calc libreoffice-impress libreoffice-writer rhythmbox brasero cheese unity-webapps-common
fi

codename=$(lsb_release -c | awk  '{print $2}')
#Note: they started deprecating the security branches (with vivid), so that's why it's missing below.
#It'll just throw 404 errors if you try to include it.
if ! [-a /etc/apt/sources.list.d/ddebs.list]
then
sudo tee /etc/apt/sources.list.d/ddebs.list << EOF
deb http://ddebs.ubuntu.com/ ${codename}      main restricted universe multiverse
deb http://ddebs.ubuntu.com/ ${codename}-updates  main restricted universe multiverse
deb http://ddebs.ubuntu.com/ ${codename}-proposed main restricted universe multiverse
EOF
fi
#if this hasn't been already run
if ! [-a ./globus-toolkit-repo_latest_all.deb]
  then
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ECDCAD72428D7C01
    wget http://toolkit.globus.org/ftppub/gt6/installers/repo/globus-toolkit-repo_latest_all.deb
    sudo dpkg -i globus-toolkit-repo_latest_all.deb
fi
sudo apt-get update
sudo apt-get install linux-image-$(uname -r)-dbgsym oprofile iperf3 emacs netperf nuttcp flowgrind systemtap --assume-yes
ch
