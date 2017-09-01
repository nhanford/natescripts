#!/bin/bash

mkdir -p /media/gridTmp
mount -t tmpfs -o size=1G tmpfs /media/gridTmp
openssl rand -out /media/gridTmp/rand.img -base64 $(( 750 * 406322000000/550229 ))

