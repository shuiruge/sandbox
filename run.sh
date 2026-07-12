#!/usr/bin/env bash
set -e

# Load .env configuration
DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/.env"

# Host directories mounted into container
mkdir -p "$WORKSPACE_DIR" "$NIX_DIR_HOST"

# Write flake.nix and flake.lock
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

        shellHook = ''
          # opencode config directory
          mkdir -p "\$PWD/.config"
          export OPENCODE_CONFIG_DIR="\$PWD/.config"
          # opencode data directory
	        mkdir -p "\$PWD/.data" "\$HOME/.local/share"
          ln -sfnT "\$PWD/.data" "\$HOME/.local/share/opencode"
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
cat << README_EOF > "$WORKSPACE_DIR/README"
Run "nix develop" in terminal to build the OpenCode environment
using Flake (an modern feature of Nix). In the first time
of building, it will download and compile so many things.
Be patient, ladies and gentlemen. Then, try "opencode" in
terminal to execute OpenCode.

Have fun :)
README_EOF

# Run docker container
docker run -it --rm \
  -v "$NIX_DIR_HOST:$NIX_DIR" \
  -v "$WORKSPACE_DIR:/home/$DEV_USER/workspace" \
  "$IMAGE_NAME"
