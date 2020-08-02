#!/bin/bash

function create_namespace() {
	name=$1
	if ! kubectl get ns $name; then
		kubectl create ns $name
		kubectl apply -f secrets/secret-tls-cert.yaml -n $name
		kubectl apply -f secrets/secret-self-signed-ca.yaml -n $name
	fi
}

# Check if hostpath is moved to /data/hostpath-provisioner
CHK_FSTAB=$(grep '/tmp/hostpath-provisioner' /etc/fstab | wc -l)
if [[ "$CHK_FSTAB" == "0" ]]; then
	sudo echo '/var/tmp/hostpath-provisioner /tmp/hostpath-provisioner none defaults,bind 0 0' >> /etc/fstab
	echo "Need a system reboot to configure new hostpath for minikube volumes. Rebooting the system in 10 seconds.."
	sleep 10
	sudo shutdown -r now
else
	sudo chmod 777 /tmp/hostpath-provisioner -R
fi

# Fix the docker socket permissions
SOCK_PERM=$(echo $(stat -c '%A' "/var/run/docker.sock"))
if [[ "$SOCK_PERM" != "srw-rw-rw-" ]]; then
	chmod 666 /var/run/docker.sock
fi

# Start minikube
sudo minikube start --driver=none

# Change owneship of kubeconfig
sudo chown -R $USER $HOME/.kube $HOME/.minikube

# Enable ingress controller
sudo minikube addons enable ingress

# wait for ingress controller pod to start
INGRESSPOD=`kubectl get pods -n kube-system | grep 'ingress-nginx-controller-' | grep '1/1' | wc -l`
while [ $INGRESSPOD -lt 1 ]; do
	sleep 1
	INGRESSPOD=`kubectl get pods -n kube-system | grep 'ingress-nginx-controller-' | grep '1/1' | wc -l`
done

# add repositories
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm repo add stable https://kubernetes-charts.storage.googleapis.com
helm repo add gitlab https://charts.gitlab.io/
helm repo update

# create tls secrets
kubectl apply -f secrets/secret-tls-cert.yaml -n default
kubectl apply -f secrets/secret-tls-cert.yaml -n kube-system

# deploy helmchart of kubernetes-dashboard
helm upgrade --install k8s-dashbaord kubernetes-dashboard/kubernetes-dashboard --namespace  kube-system --values kubernetes-dashboard-values.yaml

# create devops namespace
create_namespace devops

# deploy jenkins
helm upgrade --install jenkins stable/jenkins --namespace devops --values jenkins-values.yaml --version 2.4.1

# deploy gitlab
kubectl create secret generic gitlab-gitlab-initial-root-password --from-literal=password=$(head -c 512 /dev/urandom | LC_CTYPE=C tr -cd 'a-zA-Z0-9' | head -c 32) -n devops
kubectl apply -f secrets/secret-gitlab-gitlab-shell-host-keys.yaml -n devops
helm upgrade --install gitlab gitlab/gitlab --namespace devops --values gitlab-values.yaml --version 4.2.0

# patch ingress for ssh
kubectl patch configmap tcp-services -n kube-system --patch '{"data":{"2222":"devops/gitlab-gitlab-shell:2222"}}'
