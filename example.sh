#!/usr/bin/env bash
set -e

# Load .env configuration
DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/.env"

# Host directories mounted into container
mkdir -p "$WORKSPACE_DIR" "$NIX_DIR_HOST"

# Write flake.nix and flake.lock to setup nix environment
# Install essential packages including opencde.
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

# Write a readme
cat << README_EOF > "$WORKSPACE_DIR/readme"
In the first time of building, it will download and compile so many things.
Be patient, ladies and gentlemen.

Have fun :)
README_EOF

# Run docker container
docker run -it --rm \
  -v "$NIX_DIR_HOST:$NIX_DIR" \
  -v "$WORKSPACE_DIR:/home/$DEV_USER/workspace" \
  -w "/home/$DEV_USER/workspace" \
  -p "$PORT:$PORT" \
  "$IMAGE_NAME" \
  nix develop
