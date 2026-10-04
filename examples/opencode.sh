#!/usr/bin/env bash
set -e

# ------- Configurations -------

# Docker image tag
IMAGE_NAME=nix-dev:latest

# Workspace mount path
# TODO: You have to change this for your own.
WORKSPACE_DIR=$PWD/workspace
# Host directory for persisting Nix Store
# TODO: You have to change this for your own.
NIX_DIR_HOST=$HOME/.nix-store
# Port on both container and host.
PORT=3000

# ------- Run Docker Image -------

# Host directories mounted into container
mkdir -p "$WORKSPACE_DIR" "$NIX_DIR_HOST"

# Write script that configurates opencode
cat << INIT_EOF > "$WORKSPACE_DIR/init.sh"
# set opencode config directory
mkdir -p "\$PWD/.config"
export OPENCODE_CONFIG_DIR="\$PWD/.config"
# set opencode data directory
mkdir -p "\$PWD/.data" "\$HOME/.local/share"
ln -sfnT "\$PWD/.data" "\$HOME/.local/share/opencode"
alias opencode-tui='opencode'
alias opencode-web='opencode web --hostname 0.0.0.0 --port $PORT'
cat << OPENCODE_CONFIG_EOF > "\$PWD/.config/opencode.json"
{
    "model": "opencode/mimo-v2.5-free"
}
OPENCODE_CONFIG_EOF
# remove retired files, including init.sh itself.
rm flake.nix flake.lock init.sh
INIT_EOF

# Write flake.nix and flake.lock to setup nix environment
# Install essential packages including opencde.
cat << FLAKE_NIX_EOF > "$WORKSPACE_DIR/flake.nix"
{
  description = "opencode environment";

  inputs = {
    # 使用清华 nixpkgs.git 镜像
    nixpkgs.url = "git+https://mirrors.tuna.tsinghua.edu.cn/git/nixpkgs.git";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.\${system};
    in {
      devShells.\${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          git
          curl
          unzip
          openssl
          nodejs
          python3
          uv
          opencode
        ];

        # shell commands to run after nix develop.
        shellHook = ''
          . init.sh
        '';
      };
    };
}
FLAKE_NIX_EOF
cat << FLAKE_LOCK_EOF > "$WORKSPACE_DIR/flake.lock"
{
  "nodes": {
    "nixpkgs": {
      "locked": {
        "lastModified": 1789868263,
        "narHash": "sha256-mdzxWuTl3lPxjj9VN3R/jybOyTfL5BbYbjDUBKRHWs0=",
        "ref": "refs/heads/master",
        "rev": "8eba258d9eb6a70558fdaca27c01b66194f856f2",
        "revCount": 1076849,
        "type": "git",
        "url": "https://mirrors.tuna.tsinghua.edu.cn/git/nixpkgs.git"
      },
      "original": {
        "type": "git",
        "url": "https://mirrors.tuna.tsinghua.edu.cn/git/nixpkgs.git"
      }
    },
    "root": {
      "inputs": {
        "nixpkgs": "nixpkgs"
      }
    }
  },
  "root": "root",
  "version": 7
}
FLAKE_LOCK_EOF

# Run docker container
docker run -it --rm \
  -v "$NIX_DIR_HOST:/nix" \
  -v "$WORKSPACE_DIR:/home/dev/workspace" \
  -w "/home/dev/workspace" \
  -p "$PORT:$PORT" \
  "$IMAGE_NAME" \
  nix develop
