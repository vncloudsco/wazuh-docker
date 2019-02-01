#!/bin/bash
# Wazuh App Copyright (C) 2018 Wazuh Inc. (License GPLv2)

set -e

if [ "x${ELASTICSEARCH_URL}" = "x" ]; then
  el_url="http://elasticsearch:9200"
else
  el_url="${ELASTICSEARCH_URL}"
fi


if [ "${SEARCHGUARD}" = "enabled" ]; then
    /searchguard_app_config.sh
fi

until curl -k -XGET $el_url; do
  >&2 echo "Elastic is unavailable - sleeping"
  sleep 5
done
>&2 echo "Elastic is up - executing command"

echo "Setting API credentials into Wazuh APP"
CONFIG_CODE=$(curl -k -s -o /dev/null -w "%{http_code}" -XGET $el_url/.wazuh/wazuh-configuration/1513629884013)
if [ "x$CONFIG_CODE" = "x404" ]; then
  curl -k -s -XPOST $el_url/.wazuh/wazuh-configuration/1513629884013 -H 'Content-Type: application/json' -d'
  {
    "api_user": "foo",
    "api_password": "YmFy",
    "url": "https://wazuh",
    "api_port": "55000",
    "insecure": "true",
    "component": "API",
    "cluster_info": {
      "manager": "wazuh-manager",
      "cluster": "Disabled",
      "status": "disabled"
    },
    "extensions": {
      "oscap": true,
      "audit": true,
      "pci": true,
      "aws": true,
      "virustotal": true,
      "gdpr": true,
      "ciscat": true
    }
  }
  ' > /dev/null
else
  echo "Wazuh APP already configured"
fi
sleep 5

./wazuh_app_config.sh

sleep 5

/usr/local/bin/kibana-docker
