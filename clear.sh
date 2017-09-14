#!/bin/bash

for i in {0..6}
do
	ssh rootnh@192.168.120.19$i ifconfig eth1
done
