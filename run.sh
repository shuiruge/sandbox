#!/usr/bin/env bash
set -e

# Load .env configuration
DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/.env"

# Host workspace directory, mounted to /home/$DEV_USER/workspace inside container
mkdir -p "$DIR/$WORKSPACE_DIR"

docker run -it --rm \
  -v "$NIX_STORE_VOLUME:$NIX_STORE_DIR" \
  -v "$DIR/$WORKSPACE_DIR:/home/$DEV_USER/workspace" \
  "$IMAGE_NAME"
