# ArgoCD-CrossPlane
ArgoCD test environment, operating on a local machine using Docker Desktop.

### 1. Prerequisites
* [Docker desktop](https://www.docker.com/products/docker-desktop/)
* [kubectl](https://kubernetes.io/docs/tasks/tools/)
* [argocd](https://argo-cd.readthedocs.io/en/stable/cli_installation/)
* [helm](https://helm.sh/docs/intro/install/)

### 2. Run Docker desktop in Kubernetes mode:
Follow this [guide](https://docs.docker.com/desktop/features/kubernetes/) to configure Docker Desktop in Kubernetes mode.

### 3. Install ArgoCD
#### 3.1 Install with Helm
* Add ArgoCD Helm repo:
```bash
helm repo add argocd https://argoproj.github.io/argo-helm
```
* Update repositories cache:
```bash
helm repo update
```

* Install ArgoCD with Helm
```bash
helm install argocd argocd/argo-cd --version 7.7.6 \
  -f ./argocd/bootstrap/helm/argocd-values.yaml \
  --create-namespace \
  -n argocd
```
#### 3.2 Install ArgoCD in Argo way
* Create namespace for ArgoCD
```bash
kubectl create namespace argocd
```

* Install ArgoCD from Kubernetes manifest file(all in one)
```bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

* Patch Kubernetes Service, change type to LoadBalancer
```bash
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```

### 4. Bootstrap ArgoCD
* Apply Kubernetes manifests to finish ArgoCD bootstraping
Create Repositories, Cluster(local), ApplicationOfApplications(ApplicationSet)
```bash
kubectl apply -f ./argocd/bootstrap/manifests/
```

### 5. Get default ArgoCD password
```bash
argocd admin initial-password -n argocd
```
or 
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```
After first ArgoCD sync with repo, passwords will be changed to this from [file](./argocd/envs/dev/argocd/values.yaml).

### 6. You can use `run.sh` script
Script will run all above commands for you
```bash
sh ./run.sh
```

### 7. Open ArgoCD ui
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```
Open http://localhost:8080 in web browser

### 8. Change ArgoCD default password
```bash
argocd login localhost:8080
argocd account update-password
```
