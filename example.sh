#!/usr/bin/env bash
set -e

# Load .env configuration
DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/.env"

# Host directories mounted into container
mkdir -p "$WORKSPACE_DIR" "$NIX_DIR_HOST"

# Write script that configurates what you want
# TODO: you can modify this for your purpose.
cat << INIT_EOF > "$WORKSPACE_DIR/init.sh"
# remove retired files, including init.sh itself.
rm flake.nix flake.lock init.sh
INIT_EOF

# Write flake.nix and flake.lock to setup nix environment
# TODO: what do you want to install?
cat << FLAKE_NIX_EOF > "$WORKSPACE_DIR/flake.nix"
{
  description = "example environment";

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
        ];

        # shell commands to run after nix develop.
        shellHook = ''
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
        "lastModified": 1782625347,
        "narHash": "sha256-Jk1bzoynhAdsIzxQH3nqIVnj2X2QcoPDoOclbB8vdY0=",
        "ref": "refs/heads/master",
        "rev": "126015c9f35181565b8c30c5e220547f3fc056d2",
        "revCount": 1023778,
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
  -v "$NIX_DIR_HOST:$NIX_DIR" \
  -v "$WORKSPACE_DIR:/home/$DEV_USER/workspace" \
  -w "/home/$DEV_USER/workspace" \
  -p "$PORT:$PORT" \
  "$IMAGE_NAME" \
  nix develop
