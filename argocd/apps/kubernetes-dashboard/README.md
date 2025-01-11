### run command:
```bash
kubectl -n kubernetes-dashboard create token admin-user
```

### To get access to gui:
```bash
kubectl port-forward svc/kubernetes-dashboard-kong-proxy -n kubernetes-dashboard 8443:443
```

Open web browser: `https://localhost:8443`