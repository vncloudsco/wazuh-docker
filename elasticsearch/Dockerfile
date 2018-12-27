# Wazuh App Copyright (C) 2018 Wazuh Inc. (License GPLv2)
FROM openjdk:8-jre-alpine

# Based on khezen/docker-elasticsearch

ENV ES_TMPDIR "/tmp"
ENV ES_VERSION 6.5.4
ENV SG_VERSION "24.0"
ENV DOWNLOAD_URL "https://artifacts.elastic.co/downloads/elasticsearch"
ENV ES_TARBAL "${DOWNLOAD_URL}/elasticsearch-${ES_VERSION}.tar.gz"
ENV ES_TARBALL_ASC "${DOWNLOAD_URL}/elasticsearch-${ES_VERSION}.tar.gz.asc"
ENV GPG_KEY "46095ACC8548582C1A2699A9D27DMAINTAINER666CD88E42B4"
ENV PATH /elasticsearch/bin:$PATH

RUN apk add --no-cache --update bash ca-certificates su-exec util-linux curl openssl rsync
RUN apk add --no-cache -t .build-deps gnupg \
  && mkdir /install \
  && cd /install \
  && echo "===> Install Elasticsearch..." \
  && curl -o elasticsearch.tar.gz -Lskj "$ES_TARBAL"; \
  if [ "$ES_TARBALL_ASC" ]; then \
    curl -o elasticsearch.tar.gz.asc -Lskj "$ES_TARBALL_ASC"; \
    export GNUPGHOME="$(mktemp -d)"; \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEY"; \
    gpg --batch --verify elasticsearch.tar.gz.asc elasticsearch.tar.gz; \
    rm -r "$GNUPGHOME" elasticsearch.tar.gz.asc; \
  fi; \
  tar -xf elasticsearch.tar.gz \
  && ls -lah \
  && mv elasticsearch-$ES_VERSION /elasticsearch \
  && adduser -DH -s /sbin/nologin elasticsearch \
  && echo "===> Installing search-guard..." \
  && /elasticsearch/bin/elasticsearch-plugin install -b "com.floragunn:search-guard-6:$ES_VERSION-$SG_VERSION" \
  && echo "===> Creating Elasticsearch Paths..." \
  && for path in \
  	/elasticsearch/config \
  	/elasticsearch/config/scripts \
  	/elasticsearch/plugins \
  ; do \
  mkdir -p "$path"; \
  chown -R elasticsearch:elasticsearch "$path"; \
  done \
  && rm -rf /install \
  && rm /elasticsearch/config/elasticsearch.yml \
  && apk del --purge .build-deps


RUN  mkdir -p /.backup/elasticsearch/
COPY config /.backup/elasticsearch/config

VOLUME /elasticsearch/config
VOLUME /elasticsearch/data

EXPOSE 9200 9300

ENV CLUSTER_NAME="wazuh" \
    MINIMUM_MASTER_NODES=2 \
    HOSTS="127.0.0.1, [::1]" \
    NODE_NAME=NODE-1 \
    NODE_MASTER=true \
    NODE_DATA=true \
    NODE_INGEST=true \
    HTTP_ENABLE=true \
    HTTP_CORS_ENABLE=true \
    HTTP_CORS_ALLOW_ORIGIN=* \
    NETWORK_HOST="0.0.0.0" \
    ELASTIC_PWD="wazuhChangeme" \
    KIBANA_PWD="wazuhChangeme" \
    LOGSTASH_PWD="wazuhChangeme" \
    BEATS_PWD="wazuhChangeme" \
    HEAP_SIZE="1g" \
    CA_PWD="wazuhChangeme" \
    TS_PWD="wazuhChangeme" \
    KS_PWD="wazuhChangeme" \
	HTTP_SSL=true \
    LOG_LEVEL=INFO

COPY ./src/ /run/
RUN chmod +x -R /run/

ENTRYPOINT ["/run/entrypoint.sh"]
CMD ["elasticsearch"]