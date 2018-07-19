kind: Deployment 
apiVersion: extensions/v1beta1
metadata:
  namespace: {{.namespace}} 
  name: {{.name}} 
spec:
  replicas: 1
  template:
    metadata:
      labels:
        component: {{.name}}
    spec:
      containers:
        - name: {{.name}}
          securityContext:
            privileged: true
          image: {{.image}}
          env:
            - name: POD_IP
              valueFrom:
                fieldRef:
                  fieldPath: status.podIP
          ports:
            - containerPort: {{.port}}
          volumeMounts:
            - name: host-time
              mountPath: /etc/localtime
              readOnly: true
            - name: cgroup 
              mountPath: /sys/fs/cgroup 
              readOnly: true
            - name: {{.name}}-sh-config 
              mountPath: /workspace
              readOnly: true
            - name: {{.name}}-unit-config 
              mountPath: /etc/systemd/system/dns.service
              subPath: dns.service
              readOnly: true
      volumes:
        - name: host-time
          hostPath:
            path: /etc/localtime
        - name: cgroup 
          hostPath:
            path: /sys/fs/cgroup 
        - name: {{.name}}-sh-config 
          configMap:
            name: {{.name}}-sh-config
            defaultMode: 0755
        - name: {{.name}}-unit-config 
          configMap:
            name: {{.name}}-unit-config
