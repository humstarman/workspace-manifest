kind: Service
apiVersion: v1
metadata:
  name: {{.name}} 
spec:
  clusterIP: {{.cluster.ip}}
  ports:
    - protocol: TCP 
      port: {{.port}} 
      targetPort: {{.port}}
