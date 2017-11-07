#!/bin/bash

## Can receiver ping senders (rest slice)?
for i in 190 191 192 194 200:
do
	ssh rootnh@192.168.120.201 ping -c 3 192.168.100.$i
done

## Can receiver ping senders (TCP slice)?
for i in 111 112 113 114 115:
do
	ssh rootnh@192.168.120.116 ping -c 3 192.168.200.$i
done
