---
apiVersion: v1
kind: Service
metadata:
  namespace: {{.namespace}}
  name: gitlab
  labels:
    app: gitlab
spec:
  ports:
    - name: gitlab-ui
      port: 80
      protocol: TCP
      targetPort: 30080
      nodePort: 30080
    - name: gitlab-ssh
      port: 22
      protocol: TCP
      targetPort: 22
      nodePort: 30022
  selector:
    app: gitlab
    tier: frontend
  type: NodePort
---
apiVersion: v1
kind: Service
metadata:
  namespace: {{.namespace}}
  name: gitlab-cl
  labels:
    app: gitlab-cl
spec:
  clusterIP: {{.cluster.ip}} 
  ports:
    - name: gitlab-ui
      port: 80
      protocol: TCP
      targetPort: 80
    - name: gitlab-ssh
      port: 22
      protocol: TCP
      targetPort: 22
  selector:
    app: gitlab
    tier: frontend
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  namespace: {{.namespace}}
  name: gitlab-claim
  labels:
    app: gitlab
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  namespace: {{.namespace}}
  name: gitlab
  labels:
    app: gitlab
spec:
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: gitlab
        tier: frontend
    spec:
      serviceAccountName: gitlab
      containers:
        - image: {{.image.gitlab}} 
          name: gitlab
          env:
            - name: GITLAB_OMNIBUS_CONFIG
              value: |
                postgresql['enable'] = false
                gitlab_rails['db_username'] = "gitlab"
                gitlab_rails['db_password'] = "gitlab"
                gitlab_rails['db_host'] = "postgresql"
                gitlab_rails['db_port'] = "5432"
                gitlab_rails['db_database'] = "gitlabhq_production"
                gitlab_rails['db_adapter'] = 'postgresql'
                gitlab_rails['db_encoding'] = 'utf8'
                redis['enable'] = false
                gitlab_rails['redis_host'] = 'redis'
                gitlab_rails['redis_port'] = '6379'
                gitlab_rails['gitlab_shell_ssh_port'] = 30022
                external_url 'http://{{.cluster.ip}}:80'
                #external_url 'http://gitlab.example.com:30080'
          ports:
            - containerPort: 30080
              name: gitlab
          volumeMounts:
            - name: gitlab
              mountPath: /home/git/data
      volumes:
        - name: gitlab
          emptyDir: {} 
          #persistentVolumeClaim:
            #claimName: gitlab-claim
