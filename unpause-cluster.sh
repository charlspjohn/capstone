#!/bin/bash

SEC=60

sudo minikube start
sudo minikube unpause -A

echo "Waitning ${SEC} for minikube to unpause..."
sleep ${SEC}

# Scaling down deployments
while read deployment namespace; do
        kubectl scale deployment ${deployment} -n ${namespace} --replicas=0
done < <(kubectl get deployments --all-namespaces --no-headers | awk '{print $2,$1}')

# Delete jobs
kubectl delete jobs -n devops --all

sleep ${SEC}

# add full perm to pv path
sudo chmod -R 777 /tmp/hostpath-provisioner

# Scale up deployments
while read deployment namespace; do
        kubectl scale deployment ${deployment} -n ${namespace} --replicas=1
done < <(kubectl get deployments --all-namespaces --no-headers | awk '{print $2,$1}')

# To recreate jobs
helm repo update
helm upgrade --install gitlab gitlab/gitlab --namespace devops --values gitlab-values.yaml --version 4.2.0
helm upgrade --install jenkins stable/jenkins --namespace devops --values jenkins-values.yaml --version 2.4.1
