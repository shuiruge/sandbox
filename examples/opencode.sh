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

# Write AGENTS.md
cat << AGENTS_EOF > "$WORKSPACE_DIR/AGENTS.md"
## 约束

- 任何代码删除（包括注释）必须先说明并征得同意，不得擅自删除。
- 代码要有注释，遵循 Google style guide。在函数体中，给同一功能的代码块添加注释。
- 禁止使用单字母作为变量名。
- 在实现一个功能之后要紧跟着做测试。
- 使用英文思考，使用中文对话。要客观，不客套。表达简洁清晰，禁止使用非日常词汇（专业词汇除外），禁止使用比喻。
- 代码只使用英文，包括注释。
- **在每次输出之前都重读一遍 AGENTS.md，纠正自己的错误，直到完全符合 AGENTS.md 的要求**
AGENTS_EOF

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
if [ ! -e "\$PWD/.config/opencode.json" ]; then
    cat << OPENCODE_CONFIG_EOF > "\$PWD/.config/opencode.json"
{
    "model": "opencode/deepseek-v4-flash"
}
OPENCODE_CONFIG_EOF
fi
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
  -v "$NIX_DIR_HOST:/nix" \
  -v "$WORKSPACE_DIR:/home/dev/workspace" \
  -w "/home/dev/workspace" \
  -p "$PORT:$PORT" \
  "$IMAGE_NAME" \
  nix develop
