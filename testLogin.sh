#!/bin/bash


for i in 190 191 192 193 194 195 196
do
	ssh rootnh@192.168.120.$i << EOF
echo "DUCK"
EOF
done

for i in {1..10}
do
	ssh rootnh@192.168.120.196 echo DUCK
done
