# ArgoCD-CrossPlane
ArgoCD test environment, operating on a local machine using Docker Desktop.

## 1. Prerequisites
* [Docker desktop](https://www.docker.com/products/docker-desktop/)
* [kubectl](https://kubernetes.io/docs/tasks/tools/)
* [argocd](https://argo-cd.readthedocs.io/en/stable/cli_installation/)
* [helm](https://helm.sh/docs/intro/install/)

### 2. Run Docker desktop in Kubernetes mode:
Follow this [guide](https://docs.docker.com/desktop/features/kubernetes/) to configure Docker Desktop in Kubernetes mode.

## 3. Setup Argocd
### 3.1 Run Docker desktop in Kubernetes mode:
Follow this [guide](https://docs.docker.com/desktop/features/kubernetes/) to configure Docker Desktop in Kubernetes mode.

### 3.2 Install ArgoCD
#### 3.2.1 Install with Helm
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
#### 3.2.2 Install ArgoCD in Argo way
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

### 3.3. Bootstrap ArgoCD
* Apply Kubernetes manifests to finish ArgoCD bootstraping
Create Repositories, Cluster(local), ApplicationOfApplications(ApplicationSet)
```bash
kubectl apply -f ./argocd/bootstrap/manifests/
```

### 3.4. Get default ArgoCD password
```bash
argocd admin initial-password -n argocd
```
or 
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```
After first ArgoCD sync with repo, passwords will be changed to this from [file](./argocd/envs/dev/argocd/values.yaml).

### 3.5. You can use `run.sh` script
Script will run all above commands for you
```bash
sh ./run.sh
```

### 3.6. Open ArgoCD ui
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```
Open http://localhost:8080 in web browser

### 3.7. ArgoCD login and password change
#### 3.7.1
You can find preconfigured accounts with passwords [here](./argocd/envs/dev/argocd/values.yaml#L194-L203)

#### 3.7.2 Change ArgoCD user password
```bash
argocd login localhost:8080
argocd account update-password
```

## 4. CrossPlane
### 4.1. Set AWS credentials
#### 4.1.1 Use `run.sh` script to create secret with AWS Access Keys
If you plan to use the `run.sh` script, you must provide AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY. The script will handle creating the secret for you. You can view the relevant code [here](./run.sh#L29-L45)

#### 4.2.1. Create credential file 'aws-credentials.txt':
```toml
[default]
aws_access_key_id = XXXXXXXXXXXXXXXXXXXX
aws_secret_access_key = XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

#### 4.2.2. Create secret from file:
```bash
kubectl create secret generic aws-secret -n crossplane-system --from-file=creds=./aws-credentials.txt
```

#### 4.2.3. Save secret as file
##### WARNING: Protect your AWS credentials! The credentials provided here are invalid and are for example purposes only.!!!
```bash
kubectl get secret aws-secret -o yaml > ./argocd/envs/dev/crossplane/manifests/aws-creds-secret.yaml
```
