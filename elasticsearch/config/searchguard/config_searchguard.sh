#!/bin/bash


admin_cert_password=$(cat /searchguard/sgtlstool/out/client-certificates.readme | egrep ^CN=admin.example.com.*Password |  grep -oE '[^ ]+$' )

#hostname dependant $hostname_elasticsearch_config_snippet.yml
cat '/searchguard/sgtlstool/out/'"$HOSTNAME"'_elasticsearch_config_snippet.yml' >> /usr/share/elasticsearch/config/elasticsearch.yml
echo "xpack.security.enabled: false" >> /usr/share/elasticsearch/config/elasticsearch.yml

cat /searchguard/sg_roles.yml > /usr/share/elasticsearch/plugins/search-guard-6/sgconfig/sg_roles.yml

until curl -k -XGET "https://elasticsearch:9200"; do
  echo "Sleeping"
  >&2 echo "Elastic is unavailable - sleeping"
  sleep 5
done

chmod a+x /usr/share/elasticsearch/plugins/search-guard-6/tools/sgadmin.sh
/usr/share/elasticsearch/plugins/search-guard-6/tools/sgadmin.sh \
-cd /usr/share/elasticsearch/plugins/search-guard-6/sgconfig -icl -key \
/usr/share/elasticsearch/config/admin.key   -keypass "$admin_cert_password" -cert /usr/share/elasticsearch/config/admin.pem -cacert \
/usr/share/elasticsearch/config/root-ca.pem -h "${ELASTICSEARCH_URL}" -nhnv


#curl -k -u admin:admin "$el_url/_searchguard/authinfo?pretty"

wazuhadmin_pwd=$(bash /usr/share/elasticsearch/plugins/search-guard-6/tools/hash.sh -p $WAZUHADMIN_PWD)
admin_pwd=$(bash /usr/share/elasticsearch/plugins/search-guard-6/tools/hash.sh -p $ADMIN_PWD)


sed -i 's/$2a$12$VcCDgh2NDk07JGN0rjGbM.Ad41qVR\/YFJcgHp0UGns5JDymv..TOG/'"$admin_pwd"'/g' /usr/share/elasticsearch/plugins/search-guard-6/sgconfig/sg_internal_users.ymli 

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
/usr/share/elasticsearch/config/admin.key  -keypass "$admin_cert_password" -cert /usr/share/elasticsearch/config/admin.pem -cacert \
/usr/share/elasticsearch/config/root-ca.pem -h "${ELASTICSEARCH_URL}" -nhnv
