---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: gitlab 
  namespace: {{.namespace}}
  labels:
      kubernetes.io/cluster-service: "true"
      addonmanager.kubernetes.io/mode: Reconcile
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: gitlab 
subjects:
  - kind: ServiceAccount
    name: gitlab 
    namespace: {{.namespace}}
roleRef:
  kind: ClusterRole
  name: cluster-admin
  namespace: kube-system 
  apiGroup: rbac.authorization.k8s.io

