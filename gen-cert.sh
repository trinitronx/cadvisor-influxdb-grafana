#!/bin/bash
# Based off of:
# http://www.jamescoyle.net/how-to/1073-bash-script-to-create-an-ssl-certificate-key-and-request-csr

#Required
domain=$1
commonname=$domain

#Change to your company details
country=US
state=Colorado
locality=Broomfield
organization=ReturnPath
organizationalunit=Operations
email=ops@${domain##\*\.}

#Optional
password=IamJustATesting$$LCert193248!*

if [ -z "$domain" ]
then
    echo "Argument not present."
    echo "Useage $0 [common name]"

    exit 99
else
        wildcard_cert=$(echo "$domain" | grep -c '\*')
        if [ $wildcard_cert -gt 0 ]; then
	  # replace '*.' from domain with 'star_' for wildcard certs
	  domain="${domain/\*\./star_}"
	  # replace dots '.' with underscores '_' to avoid cert name issues with env vars that docker sets
	  domain="${domain/\./_}"
        fi
fi

echo "Generating key request for $domain"

#Generate a key
openssl genrsa -des3 -passout pass:$password -out $domain.key 2048 -noout

#Remove passphrase from the key. Comment the line out to keep the passphrase
echo "Removing passphrase from key"
openssl rsa -in $domain.key -passin pass:$password -out $domain.key

#Create the request
echo "Creating CSR"
openssl req -new -key $domain.key -out $domain.csr -passin pass:$password \
    -subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email"

echo "---------------------------"
echo "-----Below is your CSR-----"
echo "---------------------------"
echo
cat $domain.csr

echo
echo "---------------------------"
echo "-----Below is your Key-----"
echo "---------------------------"
echo
cat $domain.key
