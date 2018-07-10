# Deploying Haporxy on Kubernetes

Manifests to deploy Haproxy on Kubernetes.  
Haproxy serves as kind of a port guardian.  

## 0 Prerequisites:

1. All configurations are assuming deployment to namespace `filtre`
2. Domain names used in this project are service objects of Kubernetes.

## 1 DNS Shared

Normally, `kube-dns` only works for pod scope.  
If we wanted that to work for host scope, `/etc/resolv.conf` should be modified.  
Run on each node:
```bash
./mk-dns.sh
```

> if using `ansible`, run `ansible all -m script -a './mk-dns.sh'`

## 2 Deplying Haproxy

Run
```bash
kubectl create -f configmap.yaml
kubectl create -f daemonset.yaml
```

## 3 Modify Haproxy Rules

The configure file of haproxy is dealed by a configmap object,  
to modify the config of haproxy is to modify the content of the configmap.  

There are two choices, one:  
Run:
```bash
kubectl --namespace filtre edit configmap haproxy-config
```

or:
```bash
vim configmap.yaml
kubectl replace -f configmap.yaml
```

The haproxy daemonset would read the config file from configmap,  
and restart automatically.
