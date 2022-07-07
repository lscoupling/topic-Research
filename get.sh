#!/bin/bash
wget https://how64bit.com/tgc101-devops-demo/app.yml
wget https://how64bit.com/tgc101-devops-demo/cicd.yml
mkdir -p group_vars
cat >> group_vars/k8s << EOF
TOKEN: GR1348941vhNsi15fip2bXJq
EOF