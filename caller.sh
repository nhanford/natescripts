#!/bin/bash

ssh rootnh@192.168.120.193 << EOF
cd ~/natescripts
git pull
./revTest.sh
EOF

d=$(date +%F-%H-%M)
mkdir ~/$d
scp nhanford@192.168.120.192:~/*.txt ~/$d
ssh nhanford@192.168.120.192 rm *.txt

cp nPlots.py ~/$d
cd ~/$d
./nPlots.py

