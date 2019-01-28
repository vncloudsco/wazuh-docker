# Wazuh App Copyright (C) 2018 Wazuh Inc. (License GPLv2)
FROM docker.elastic.co/elasticsearch/elasticsearch:6.5.4
ENV ES_TMPDIR "/tmp"
ENV ES_VERSION 6.5.4
ENV SG_VERSION "24.0"


#ENV elasticsearch "/usr/share/elasticsearch/"

COPY config/entrypoint.sh /entrypoint.sh
COPY config/sg_roles.yml /sg_roles.yml
#COPY config/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml

RUN chmod 755 /entrypoint.sh

RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install -b "com.floragunn:search-guard-6:$ES_VERSION-$SG_VERSION" 

RUN chmod +x -R /run/

ENTRYPOINT /entrypoint.sh

