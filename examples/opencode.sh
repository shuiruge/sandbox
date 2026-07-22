#!/usr/bin/env bash
set -e

# Load .env configuration
DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/.env"

# Host directories mounted into container
mkdir -p "$WORKSPACE_DIR" "$NIX_DIR_HOST"


cat << INIT_EOF > "$WORKSPACE_DIR/init.sh"
# set opencode config directory
mkdir -p "\$PWD/.config"
export OPENCODE_CONFIG_DIR="\$PWD/.config"
# set opencode data directory
mkdir -p "\$PWD/.data" "\$HOME/.local/share"
ln -sfnT "\$PWD/.data" "\$HOME/.local/share/opencode"
alias opencode-tui='opencode'
alias opencode-web='opencode web --hostname 0.0.0.0 --port $PORT'
if [ ! -e "\$PWD/.config/opencode.json" ]; then
    cat << OPENCODE_CONFIG_EOF > "\$PWD/.config/opencode.json"
{
    "model": "opencode/mimo-v2.5-free"
}
OPENCODE_CONFIG_EOF
fi
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
          source init.sh
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

Then use opencode-tui to execute opencode in TUI, or opencode-web for web mode.

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
