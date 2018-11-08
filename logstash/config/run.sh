#!/bin/bash
# Wazuh App Copyright (C) 2018 Wazuh Inc. (License GPLv2)
#
# OSSEC container bootstrap. See the README for information of the environment
# variables expected by this script.
#

#

#
# Apply Templates
#

set -e
host="elasticsearch"
host2="elasticsearch2"
host3="elasticsearch3"
until curl -XGET $host:9200 || curl  -XGET $host2:9200 || curl  -XGET $host3:9200; do
  >&2 echo "Elastic is unavailable - sleeping"
  sleep 1
done

# Add logstash as command if needed
if [ "${1:0:1}" = '-' ]; then
	set -- logstash "$@"
fi

# Run as user "logstash" if the command is "logstash"
if [ "$1" = 'logstash' ]; then
	set -- gosu logstash "$@"
fi

exec "$@"
