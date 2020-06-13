# capstone
openssl genrsa -out ./cyborgdc.com.key 2048
openssl req -config cyborgdc.com.cfg -new  -key ./cyborgdc.com.key -out ./cyborgdc.com.csr -verbose
openssl x509 -req -in cyborgdc.com.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out cyborgdc.com.crt -days 500 -sha256
rsync -av rootCA.crt cyborgdc.com.crt cyborgdc.com.key charlspjohn@jenkins.cyborgdc.com:~/
