#!/bin/bash

# Create the CA
if [ ! -f authority/authority.key ]; then
  openssl genrsa -des3 -out authority/authority.key -passout pass:1234 4096
fi
if [ ! -f authority/authority.crt ]; then
  openssl req -x509 -new -key authority/authority.key -out authority/authority.crt -days 3650 -passin pass:1234 -config authority/ssl.conf
fi

# Create the CA .p12 file (windows)
if [ ! -f authority/authority.p12 ]; then
  openssl pkcs12 -export -out authority/authority.p12 -password pass:1234 -in authority/authority.crt -nokeys
fi

declare -a dirs=("portainer")
for dir in "${dirs[@]}"
do
  if [ ! -f $dir/private.key ]; then
    # Create the certificate request
    openssl genrsa -out $dir/private.key -passout pass:1234 4096
    openssl req -new -sha256 -out $dir/private.csr -key $dir/private.key -extensions req_ext -config $dir/ssl.conf

    # Sign and create the certificate
    openssl x509 -req -sha256 -days 3650 -in $dir/private.csr -CA authority/authority.crt -CAkey authority/authority.key -CAcreateserial -out $dir/private.crt -passin pass:1234 -extensions req_ext -extfile $dir/ssl.conf
  fi
done
