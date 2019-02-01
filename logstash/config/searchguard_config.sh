#!/bin/bash

if [ "${SEARCHGUARD}" = "enabled" ]; then
logstash_config_file="/usr/share/logstash/pipeline/01-wazuh.conf"
echo "antes"
cat $logstash_config_file


if [ "x${LOGSTASH_USER_PWD}" = "x" ]; then
  logstash_user_pwd="logstash"
else
  logstash_user_pwd="${LOGSTASH_USER_PWD}"
fi

sed -i 's/.*logstash_elasticsearch_ssl =>.*/        ssl =>  true/' $logstash_config_file
sed -i 's/.*cacert => .*/        cacert => \/usr\/share\/logstash\/config\/root-ca.pem/' $logstash_config_file

declare -A CONFIG_MAP=(
  [user]="logstash"
  [password]=$logstash_user_pwd
  [ssl_certificate_verification]="true"
)

for i in "${!CONFIG_MAP[@]}"
do
    if [ "${CONFIG_MAP[$i]}" != "" ]; then
        sed -i 's/.*# *'"$i"'.*/        '"$i"' => '"${CONFIG_MAP[$i]}"'/' $logstash_config_file
    fi
done



echo "saliendo de  configurar searchguard"
echo "despues:"
cat $logstash_config_file

fi
