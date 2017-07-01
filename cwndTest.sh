#!/bin/bash

for i in 1 2 3 4 5 6 7 8 9 10 11
do
    iperf3 -ZVRJi.1 -c 127.0.0.1 -F ${i}m.json
done

mkdir ~/`date +%F-%H-%M`
mv *.json ~/`date +%F-%H-%M`/
