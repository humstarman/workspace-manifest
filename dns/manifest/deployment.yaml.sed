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
            - name: {{.name}}-config 
              mountPath: /workspace
      volumes:
        - name: host-time
          hostPath:
            path: /etc/localtime
        - name: cgroup 
          hostPath:
            path: /sys/fs/cgroup 
        - name: {{.name}}-config 
          configMap:
            name: {{.name}}-config
            defaultMode: 0755
