#!/bin/bash

for i in {0..6}
do
	echo 192.168.120.19$i
	ssh rootnh@192.168.120.19$i ls -al /tmp
done
