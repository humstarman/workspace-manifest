kind: Deployment
apiVersion: extensions/v1beta1
metadata:
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
          image: {{.image}}
          imagePullPolicy: IfNotPresent
          command:
            - /file-server
          args:
            - -p
            - "80"
          ports:
            - containerPort: 80
          resources:
            requests:
              cpu: 100m
          volumeMounts:
            - name: files
              mountPath: /mnt
            - name: host-time
              mountPath: /etc/localtime
              readOnly: true
      nodeSelector:
        {{.selector}}: "true"
      volumes:
        - name: files
          hostPath:
            path: {{.shared}}
        - name: host-time
          hostPath:
            path: /etc/localtime
