#!/bin/bash

if [ ! -x "$(command -v kubectl)" ]; then
  echo "$(date) - [ERROR] - no kubectl installed!"
  exit 1
fi

kubectl create -f namespace.yaml
kubectl create -f local-volumes.yaml
kubectl create -f postgres.yaml
kubectl create -f redis.yaml
kubectl create -f gitlab.yaml
