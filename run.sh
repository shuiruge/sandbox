#!/usr/bin/env bash
set -e

# Load .env configuration
DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/.env"

# Host directories mounted into container
mkdir -p "$DIR/$WORKSPACE_DIR" "$DIR/$NIX_DIR_HOST"

docker run -it --rm \
  -v "$DIR/$NIX_DIR_HOST:$NIX_DIR" \
  -v "$DIR/$WORKSPACE_DIR:/home/$DEV_USER/workspace" \
  "$IMAGE_NAME"
