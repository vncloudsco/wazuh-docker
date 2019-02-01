#!/bin/bash
# Wazuh App Copyright (C) 2018 Wazuh Inc. (License GPLv2)


if [ "${SEARCHGUARD}" = "enabled" ]; then
kibana_config_file="/usr/share/kibana/config/kibana.yml"

NODE_OPTIONS="--max-old-space-size=8192" /usr/share/kibana/bin/kibana-plugin install --no-optimize https://search.maven.org/remotecontent?filepath=com/floragunn/search-guard-kibana-plugin/${ES_VERSION}-${SG_VERSION}/search-guard-kibana-plugin-${ES_VERSION}-${SG_VERSION}.zip 

if [ "x${KIBANA_USER_PWD}" = "x" ]; then
  kibana_user_pwd="admin"
else
  kibana_user_pwd="${KIBANA_USER_PWD}"
fi

sed -i 's/.*elasticsearch.url:.*/elasticsearch.url: "https:\/\/elasticsearch:9200"/' $kibana_config_file
sed -i 's/.*elasticsearch.requestHeadersWhitelist:.*/elasticsearch.requestHeadersWhitelist: [ "Authorization" , "sgtenant" ]/' $kibana_config_file
sed -i 's/.*elasticsearch.ssl.certificateAuthorities:.*/elasticsearch.ssl.certificateAuthorities: \/usr\/share\/kibana\/config\/root-ca.pem/' $kibana_config_file

declare -A CONFIG_MAP=(
  [elasticsearch.username]="admin"
  [elasticsearch.password]="$kibana_user_pwd"
  [xpack.security.enabled]="false"
  [elasticsearch.ssl.verificationMode]="certificate"
)

for i in "${!CONFIG_MAP[@]}"
do
    if [ "${CONFIG_MAP[$i]}" != "" ]; then
        sed -i 's/.*#'"$i"'.*/'"$i"': '"${CONFIG_MAP[$i]}"'/' $kibana_config_file
    fi
done



fi
