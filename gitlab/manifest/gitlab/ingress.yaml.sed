apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: my-{{.name}}-ingress
  namespace: {{.namespace}}
spec:
  rules:
  - host: {{.url}} 
    http:
      paths:
      - path: /
        backend:
          serviceName: gitlab-cl
          servicePort: 80

