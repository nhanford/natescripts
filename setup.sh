#!/bin/bash

for i in {0..6}
do
scp ~/.ssh/id
ssh -o StrictHostKeyChecking=no rootnh@192.168.120.19$i << EOF
chsh rootnh -s /bin/bash
git clone git@github.com:nhanford/natescripts.git
EOF
done
