#!/bin/bash

# changed from: https://medium.com/@ophamster/elasticsearch-with-search-guard-on-gke-239173dc4048
# previous: https://github.com/khezen/docker-elasticsearch/blob/master/src/entrypoint.sh

set -m

export NODE_NAME=$(hostname)

/run/miscellaneous/restore_config.sh
/run/auth/certificates/gen_all.sh

# Run as user "elasticsearch" if the command is "elasticsearch"
if [ "$1" = 'elasticsearch' -a "$(id -u)" = '0' ]; then
	chown -R elasticsearch:elasticsearch /usr/share/elasticsearch
	set -- gosu elasticsearch "$@"
	ES_JAVA_OPTS="-Des.network.host=$NETWORK_HOST -Des.logger.level=INFO -Xms$HEAP_SIZE -Xmx$HEAP_SIZE" $@ &
else
	$@ &
fi

if [ "$HTTPENABLE" == "true" ]; then
	/run/miscellaneous/wait_until_started.sh
	/run/miscellaneous/index_level_settings.sh
fi

sleep 30s

# so that elasticsearch has enough time to start otherwise calling sgadmin.sh would just throw an error
# saying that elasticsearch is not running

cat /usr/share/elasticsearch/config/elasticsearch.yml

/run/auth/users.sh
/run/auth/sgadmin.sh

fg
