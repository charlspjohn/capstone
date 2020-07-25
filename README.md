# capstone
openssl genrsa -out ./cyborgdc.com.key 2048
openssl req -config cyborgdc.com.cfg -new  -key ./cyborgdc.com.key -out ./cyborgdc.com.csr -verbose
openssl x509 -req -in cyborgdc.com.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out cyborgdc.com.crt -days 500 -sha256
rsync -av rootCA.crt cyborgdc.com.crt cyborgdc.com.key charlspjohn@jenkins.cyborgdc.com:~/
kubectl create secret tls tls-cert --key cyborgdc.com.key --cert cyborgdc.com.crt -n devops
kubectl get secret postgres-ro-secret -n 2020q2 -o json | jq -r '.data |  map_values(@base64d)'
gsutil versioning set on gs://[BUCKET_NAME]




while read dp ns; do kubectl scale deployment $dp -n $ns --replicas=0; done < <(kubectl get deployments --all-namespaces --no-headers | awk '{print $2,$1}')
kubectl delete jobs --all-namespaces --all
sudo minikube stop
sudo shutdown -h now
