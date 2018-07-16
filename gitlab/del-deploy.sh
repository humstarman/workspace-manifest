#!/bin/bash

NEEDS="kubectl ansible"

for NEED in $NEEDS; do
  if [ ! -x "$(command -v $NEED)" ]; then
    echo "$(date) - [ERROR] - no $NEED installed!"
    exit 1
  fi
done

kubectl delete -f . 
ansible all -m shell -a "rm -rf /data2/*"
