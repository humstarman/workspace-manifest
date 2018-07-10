---
apiVersion: extensions/v1beta1 
kind: DaemonSet
metadata:
  name: {{.ds}}
  labels:
    addonmanager.kubernetes.io/mode: Reconcile
spec:
  template:
    metadata:
      labels:
        app: {{.ds}}
    spec:
      terminationGracePeriodSeconds: 1
      containers:
      - name: {{.ds}} 
        image: {{.image}}
        command:
        - /bin/sh
        - -c
        - |
          while true; do
            sleep 60
          done
