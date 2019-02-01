#!/bin/bash

set -m


if [ "${SEARCHGUARD}" = "enabled" ]; then

    if [ ! -f /usr/share/elasticsearch/config/admin.pem ]; then

        /usr/share/elasticsearch/bin/elasticsearch-plugin install -b "com.floragunn:search-guard-6:$ES_VERSION-$SG_VERSION" 

        chmod +x  /searchguard/generate_certificates.sh
        chmod +x  /searchguard/config_searchguard.sh

        cd /searchguard
        /searchguard/generate_certificates.sh

        su -c "/usr/share/elasticsearch/bin/elasticsearch &" elasticsearch

        /searchguard/config_searchguard.sh
        cd ..

        rm -R /searchguard

    fi

  else

        su -c "/usr/share/elasticsearch/bin/elasticsearch &" elasticsearch
fi

#Insert default templates
cat /usr/share/elasticsearch/config/wazuh-elastic6-template-alerts.json | curl -k -u admin:admin -XPUT "https://127.0.0.1:9200/_template/wazuh" -H 'Content-Type: application/json' -d @-




pkill -f elasticsearch


su -c "/usr/share/elasticsearch/bin/elasticsearch " elasticsearch
