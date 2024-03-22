#!/bin/bash

ES_USER=elastic

source .env

function usage() {
  echo "Usage"
}

function health {
  curl -k -u $ES_USER:$ES_PASSWORD https://$EP/_cat/health?v
}

function nodes {
  curl -k -u $ES_USER:$ES_PASSWORD https://$EP/_cat/nodes?v  
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
