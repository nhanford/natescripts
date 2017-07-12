#!/bin/bash
# to be run on kelewan.cs.ucdavis.edu


for i in 1000 2000 3000 4000 5000 6000 7000 8000 9000 10000
do
    sudo ifconfig eth3 txqueuelen $i
done
