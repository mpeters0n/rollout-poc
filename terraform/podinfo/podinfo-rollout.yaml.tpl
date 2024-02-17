apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  namespace: ${namespace}
  name: ${app_name}
spec:
  strategy:
    canary:
      canaryService: ${app_name}-canary
      stableService: ${app_name}-stable
      trafficRouting:
        nginx:
          stableIngress: podinfo-ingress
      analysis:
        templates:
        - templateName: success-rate
        args:
        - name: service-name
          value: ${app_name}-canary
      steps:
      - setWeight: 10
      - setWeight: 20
      - setWeight: 40
      - setWeight: 60
  revisionHistoryLimit: 2
  selector:
    matchLabels:
      app: ${app_name}
  workloadRef:
    apiVersion: apps/v1
    kind: Deployment
    name: ${app_name}
