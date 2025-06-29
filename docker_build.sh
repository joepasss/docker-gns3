#!/bin/bash

SCRIPT_DIR="$(dirname "$(realpath "$0")")"

IMAGE_NAME="gns3:local"
CONTAINER_NAME="gns3"

docker build \
  --build-arg IS_PROD=false \
  -t "$IMAGE_NAME" "$SCRIPT_DIR"

if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  docker rm -f "$CONTAINER_NAME" >/dev/null
fi

docker run -it \
  --name "$CONTAINER_NAME" \
  --net=host --privileged \
  -e BRIDGE_ADDRESS="172.21.1.1/24" \
  -v "$HOME/gns3-server:/data" \
  "$IMAGE_NAME"
