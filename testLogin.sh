#!/bin/bash


for i in 190 191 192 193 194 195 196
do
	ssh 192.168.120.$i << EOF
echo "DUCK"
EOF
done
