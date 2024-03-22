#!/bin/bash -e

source .env

function usage() {
  echo "Usage"
}

function health {
  curl -k -u $ELASTIC_USER:$ES_PASSWORD https://$EP/_cat/health?v
}

function nodes {
  curl -k -u $ELASTIC_USER:$ES_PASSWORD https://$EP/_cat/nodes?v  
}

function index {
  curl -k -u $ELASTIC_USER:$ES_PASSWORD https://$EP/_cat/indices?v
}

function shards {
  curl -k -u $ELASTIC_USER:$ES_PASSWORD https://$EP/_cat/shards?v
}

function threadpools {
  curl -k -u $ELASTIC_USER:$ES_PASSWORD https://$EP/_cat/thread_pool?v
}

function disk {
  curl -k -u $ELASTIC_USER:$ES_PASSWORD https://$EP/_cat/allocation?v
}

function pendingtasks {
  curl -k -u $ELASTIC_USER:$ES_PASSWORD https://$EP/_cat/pending_tasks?v
}

function main {
  if [ "$1" = "" ]; then
    usage;
  else
    cmd=$1
    shift;
    $cmd $*
  fi
}

main "$@"
