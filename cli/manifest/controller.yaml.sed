kind: Deployment
apiVersion: extensions/v1beta1
metadata:
  name: {{.name}}
  namespace: {{.namespace}}
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
          imagePullPolicy: {{.image.pull.policy}} 
          command:
            - /usr/bin/tail 
          args:
            - -f
            - /dev/null 
      volumes:
        - name: host-time
          hostPath:
            path: /etc/localtime
