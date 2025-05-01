#!/bin/bash

# Default values
isAuthEnabled=false
pullImagesOnly=false

# Parse flags
while getopts ":ai" opt; do
  case ${opt} in
    a )
      isAuthEnabled=true
      ;;
    i )
      pullImagesOnly=true
      ;;
    \? )
      echo "Usage: $0 [-a] [-i]"
      exit 1
      ;;
  esac
done

# remove any containers from previous run
docker compose rm -f

# Determine the compose file to use
compose_file="docker-compose.yml"


docker compose pull

# If the pullImagesOnly flag is set, exit after pulling images
if [ "$pullImagesOnly" = true ]; then
    exit 0
fi

docker compose -f "$compose_file" up