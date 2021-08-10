# hello_world
A Hello World Application built using Flask framework on Python and deployed on an EKS cluster running on AWS.

The EKS Cluster "helloworld_cluster" and a node group "nodegroup1" are created on AWS using Terraform and terraform templates can be found under the terraform directory.

Continuous Deployment of the app is done by ArgoCD, which monitors the app repository for commits and does an automatic deploy when it detects changes.

