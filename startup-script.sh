#!/bin/bash

# Start minikube
sudo minikube start --driver=none

# Change owneship of kubeconfig
sudo chown -R $USER $HOME/.kube $HOME/.minikube

# Enable ingress controller
sudo minikube addons enable ingress

# deploy helmchart of kubernetes-dashboard
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm repo update
helm upgrade --install k8s-dashbaord kubernetes-dashboard/kubernetes-dashboard --namespace  kube-system --values kubernetes-dashboard-values.yaml

# create devops namespace
kubectl create ns devops

# deploy jenkins
helm repo add stable https://kubernetes-charts.storage.googleapis.com
helm repo update
helm upgrade --install jenkins stable/jenkins --namespace devops --values jenkins-values.yaml

# deploy gitlab

