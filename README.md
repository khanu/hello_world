# hello_world
A Hello World Application built using Flask framework on Python and deployed on an EKS cluster running on AWS.

The EKS Cluster "helloworld_cluster" and a node group "nodegroup1" are created on AWS using Terraform and terraform templates can be found under the terraform directory.

Continuous Deployment of the app is done by ArgoCD, which monitors the app repository for commits and does an automatic deploy when it detects changes.

First, bring up the infrastructure using terraform
```
terraform apply
```
Next, install & setup ArgoCD using the following commands :
```
kubectl create namespace argocd
kubectl apply -n argocd -f argocd/install.yaml
```
We have our Argo app defined in declarative format under argocd/app.yaml. So all we need to do is use kubectl to deploy the argo app :
```
kubectl apply -f argocd/app.yaml
```
Use the [ArgoCD Getting Started page](https://argoproj.github.io/argo-cd/getting_started/) for understanding how to retreive the ArgoCD admin credentials and do a port-forwarding to run the ArgoCD UI from your local.

You will be able to see that the app has been deployed from the ArgoCD UI. Alternatively, you can use the UI itself to deploy the app rather than kubectl commands.
Any changes made to the app repo (app/deployment.yaml) is auto-detected by Argo and it is treated as the desired state, and it applies it to the current state (Currently running app).
