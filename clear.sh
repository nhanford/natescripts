#!/bin/bash

for i in 190 191 192 193 194 200 201
do
	ssh rootnh@192.168.120.$i pkill gridftp
done
