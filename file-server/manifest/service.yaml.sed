kind: Service
apiVersion: v1
metadata:
  name: {{.name}} 
spec:
  type: ClusterIP
  clusterIP: {{.service.ip}}
  ports:
    - port: 80
      targetPort: 80
      name: http
  selector:
    component: {{.name}}
