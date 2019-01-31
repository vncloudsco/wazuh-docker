# Wazuh App Copyright (C) 2018 Wazuh Inc. (License GPLv2)
FROM docker.elastic.co/elasticsearch/elasticsearch:6.5.4

ENV PATTERN="" \
    CHECKS_PATTERN="" \
    CHECKS_TEMPLATE="" \
    ES_VERSION="6.5.4" \
    SG_VERSION="24.0" \
    SEARCHGUARD="disabled"\ 
    WAZUHADMIN_PWD="changeme" \
    ADMIN_PWD="admin" 

ADD https://raw.githubusercontent.com/wazuh/wazuh/3.8/extensions/elasticsearch/wazuh-elastic6-template-alerts.json /usr/share/elasticsearch/config
COPY config/entrypoint.sh /entrypoint.sh

COPY config/searchguard /searchguard
COPY config/root-ca.pem /usr/share/elasticsearch/config
COPY config/root-ca.key /usr/share/elasticsearch/config


RUN chmod 755 /entrypoint.sh

RUN chmod +x -R /run/

ENTRYPOINT /entrypoint.sh
