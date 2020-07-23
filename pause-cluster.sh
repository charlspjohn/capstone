#!/bin/bash

WAIT=10
sudo minikube pause -A

echo "Waiting ${WAIT} seconds for minikube to pause all namespaces.."
sleep ${WAIT}

sudo shutdown -h now
