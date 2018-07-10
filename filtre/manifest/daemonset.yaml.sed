apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  labels:
    component: haproxy
  name: haproxy-node
  namespace: filtre
spec:
  selector:
    matchLabels:
      component: haproxy
  template:
    metadata:
      labels:
        component: haproxy
    spec:
      terminationGracePeriodSeconds: 3
      hostNetwork: true
      restartPolicy: Always
      containers:
        - name: haproxy-node
          image: {{.image}}
          command:
            - haproxy
            - -f
            - /etc/haproxy/haproxy.cfg
          ports:
            - containerPort: 8089 
              hostPort: 8089
              name: test 
          volumeMounts:
            - name: haproxy-config 
              mountPath: /etc/haproxy
              readOnly: true
            - name: host-time
              mountPath: /etc/localtime
              readOnly: true
          livenessProbe:
            exec:
              command:
                - /liveness-probe.sh
            initialDelaySeconds: 15
            periodSeconds: 5
      nodeSelector:
        edgenode: "true"
      volumes:
        - name: haproxy-config 
          configMap:
            name: haproxy-config 
        - name: host-time
          hostPath:
            path: /etc/localtime

