#!/bin/bash
chmod 777 -R /tmp/host*
minikube start
sleep 5
minikube unpause -A
