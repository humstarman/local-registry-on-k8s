kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: {{.pv.name}} 
  namespace: {{.namespace}}
  annotations:
    volume.beta.kubernetes.io/storage-class: "slow"
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 100Gi
