#!/bin/bash

mkdir sgtlstool
cd sgtlstool
wget https://search.maven.org/remotecontent?filepath=com/floragunn/search-guard-tlstool/1.6/search-guard-tlstool-1.6.tar.gz -O search-guard-tlstool-1.6.tar.gz && \
tar -xvzf search-guard-tlstool-1.6.tar.gz

sed -i 's/      pkPassword: ${CA_PWD}/      pkPassword: '"$CA_PWD"'/g' /searchguard/tlsconfig.yml
sed -i 's/- name: elasticsearch/- name: '"$HOSTNAME"'/g' /searchguard/tlsconfig.yml
sed -i 's/dn: CN=elasticsearch/dn: CN='"$HOSTNAME"'/g' /searchguard/tlsconfig.yml

mkdir out && cp /usr/share/elasticsearch/config/root-ca.pem out/ && cp /usr/share/elasticsearch/config/root-ca.key out/
tools/sgtlstool.sh -c /searchguard/tlsconfig.yml  -crt

cp out/*.pem /usr/share/elasticsearch/config
cp out/*.key /usr/share/elasticsearch/config

cd ..
