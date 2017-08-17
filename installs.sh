#!/bin/bash

for i in 190 191 192 193 194 195
do
	ssh rootnh@192.168.120.${i} pip install pycurl &
done
