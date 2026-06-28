#!/usr/bin/env bash
set -e

# Load .env configuration
DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/.env"

# Remove containers started from this image
docker ps -a | grep "$IMAGE_NAME" | awk '{print $1}' | xargs -r docker rm -f

# Remove Nix Store persistent volume
docker volume rm "$NIX_STORE_VOLUME"
