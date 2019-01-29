#!/bin/bash

set -m

# Add elasticsearch as command if needed
if [ "${1:0:1}" = '-' ]; then
	set -- elasticsearch "$@"
fi

if [ "$NODE_NAME" = "" ]; then
	export NODE_NAME=$HOSTNAME
fi


if [ "x${ELASTICSEARCH_URL}" = "x" ]; then
  el_url="https://elasticsearch:9200"
else
  el_url="${ELASTICSEARCH_URL}"
fi

#cat /elasticsearch/config/elasticsearch.yml

# chown -R 700 /elasticsearch/config
#:q

# Run as user "elasticsearch" if the command is "elasticsearch"
if [ "$1" = 'elasticsearch' -a "$(id -u)" = '0' ]; then
	set -- su-exec eulasticsearch "$@"
	ES_JAVA_OPTS="-Des.network.host=$NETWORK_HOST -Des.logger.level=$LOG_LEVEL -Xms$HEAP_SIZE -Xmx$HEAP_SIZE"  $@ &
else
	$@ &
fi



mkdir sgtlstool && cd sgtlstool && \
  wget https://search.maven.org/remotecontent?filepath=com/floragunn/search-guard-tlstool/1.6/search-guard-tlstool-1.6.tar.gz -O search-guard-tlstool-1.6.tar.gz && \
  tar -xvzf search-guard-tlstool-1.6.tar.gz


tools/sgtlstool.sh -c /tlsconfig.yml -ca -crt

cp out/*.pem /usr/share/elasticsearch/config
cp out/*.key /usr/share/elasticsearch/config

admin_cert_password=$(cat out/client-certificates.readme | egrep ^CN=kirk.example.com.*Password |  grep -oE '[^ ]+$' )
#hostname dependant $hostname_elasticsearch_config_snippet.yml
cat out/localhost_elasticsearch_config_snippet.yml >> /usr/share/elasticsearch/config/elasticsearch.yml
echo "xpack.security.enabled: false" >> /usr/share/elasticsearch/config/elasticsearch.yml

cd ..


#chmod a+x /usr/share/elasticsearch/plugins/search-guard-6/tools/install_demo_configuration.sh


#/usr/share/elasticsearch/plugins/search-guard-6/tools/install_demo_configuration.sh -y


su -c "elasticsearch &" elasticsearch


cat /sg_roles.yml > /usr/share/elasticsearch/plugins/search-guard-6/sgconfig/sg_roles.yml





cat $el_url
until curl -k -XGET $el_url; do
  echo "Sleeping"
  >&2 echo "Elastic is unavailable - sleeping"
  sleep 5
done





chmod a+x /usr/share/elasticsearch/plugins/search-guard-6/tools/sgadmin.sh
/usr/share/elasticsearch/plugins/search-guard-6/tools/sgadmin.sh \
-cd /usr/share/elasticsearch/plugins/search-guard-6/sgconfig -icl -key \
/usr/share/elasticsearch/config/kirk.key   -keypass "$admin_cert_password" -cert /usr/share/elasticsearch/config/kirk.pem -cacert \
/usr/share/elasticsearch/config/root-ca.pem -h "${ELASTICSEARCH_URL}" 


#/run/wait_until_started.sh
curl -k -u admin:admin "$el_url/_searchguard/authinfo?pretty"





wazuhadmin_pwd=$(bash /usr/share/elasticsearch/plugins/search-guard-6/tools/hash.sh -p $WAZUHADMIN_PWD)

echo "
wazuhadmin:
  hash: $wazuhadmin_pwd
  roles:
    - wazuhadmin_role" >> /usr/share/elasticsearch/plugins/search-guard-6/sgconfig/sg_internal_users.yml 





echo "
sg_wazuh_admin:
  backendroles:
    - wazuhadmin_role" >> /usr/share/elasticsearch/plugins/search-guard-6/sgconfig/sg_roles_mapping.yml


/usr/share/elasticsearch/plugins/search-guard-6/tools/sgadmin.sh \
-cd /usr/share/elasticsearch/plugins/search-guard-6/sgconfig -icl -key \
/usr/share/elasticsearch/config/kirk.key  -keypass "$admin_cert_password" -cert /usr/share/elasticsearch/config/kirk.pem -cacert \
/usr/share/elasticsearch/config/root-ca.pem -h "${ELASTICSEARCH_URL}" 


#Insert default templates
cat /usr/share/elasticsearch/config/wazuh-elastic6-template-alerts.json | curl -k -u admin:admin -XPUT "https://127.0.0.1:9200/_template/wazuh" -H 'Content-Type: application/json' -d @-




pkill -f elasticsearch

#/run/auth/users.sh
#/run/auth/sgadmin.sh

su -c "elasticsearch " elasticsearch
