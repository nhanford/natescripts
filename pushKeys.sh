#!/bin/bash

for i in kelewan vishal tilera pear kiwi ahmed2235 yliu
do
	sudo scp authorized_keys nate@$i:/home/hchauhan/.ssh/authorized_keys
	ssh nate@$i << EOF
sudo chmod 644 /home/hchauhan/.ssh/authorized_keys
sudo chown hchauhan authorized_keys
EOF
done

