#!/bin/bash

# First check if the gandi cli is properly configured, otherwise configure it

while true ; do
  # Get my current IP
  my_ip=$(curl -s https://api.ipify.org)

  # Get my currently registered IP
  current_record=$(curl -s -H "Authorization: Apikey $GANDI_API_KEY" https://api.gandi.net/v5/livedns/domains/$GANDI_DOMAIN/records/$GANDI_HOST | jq -c '.[] | select(.rrset_type == "A")')
  current_ip=$(echo $current_record | jq -r '.rrset_values[0]')
  echo "Current registered IP is $current_ip"

  # If they do not match, change it (and keep the TTL and TYPE)
  if [[ "$my_ip" != "$current_ip" ]]; then
    echo "Updating $GANDI_HOST.$GANDI_DOMAIN record with IP $my_ip"
    current_ttl=$(echo $current_record | jq -r '.rrset_ttl')
    curl -s -X PUT -H "Content-Type: application/json" -H "Authorization: Apikey $GANDI_API_KEY" -d "{\"rrset_type\": \"A\",\"rrset_ttl\": 1800,\"rrset_values\": [\"$my_ip\"]}" https://api.gandi.net/v5/livedns/domains/$GANDI_DOMAIN/records/$GANDI_HOST/A
  fi

  echo "Updating finished"

  # Wait 5 minutes
  sleep 300
done
