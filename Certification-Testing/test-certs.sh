#!/bin/bash

# Prompt the user to input a URL
read -p "Please enter the URL: " url

# Ensure the URL has a scheme (http/https)
if [[ ! $url =~ ^http ]]; then
  url="https://$url"
fi

# Extract the hostname from the URL
hostname=$(echo $url | awk -F[/:] '{print $4}')

# Use OpenSSL to retrieve the certificate
cert_info=$(echo | openssl s_client -servername $hostname -connect $hostname:443 2>/dev/null | openssl x509 -noout -text)

# Check if certificate information is available
if [[ -n "$cert_info" ]]; then
  echo "Certificate information for $url:"
  echo "Subject: $(echo "$cert_info" | grep 'Subject:' | sed 's/Subject: //')"
  echo "Issuer: $(echo "$cert_info" | grep 'Issuer:' | sed 's/Issuer: //')"
  echo "Thumbprint: $(echo "$cert_info" | openssl x509 -noout -fingerprint | sed 's/SHA1 Fingerprint=//')"
  echo "Valid From: $(echo "$cert_info" | grep 'Not Before:' | sed 's/Not Before: //')"
  echo "Valid To: $(echo "$cert_info" | grep 'Not After :' | sed 's/Not After : //')"
else
  echo "No certificate information available for $url."
fi
