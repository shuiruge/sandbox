{
  description = "opencode environment";

  inputs = {
    # 使用清华 nixpkgs.git 镜像
    nixpkgs.url = "git+https://mirrors.tuna.tsinghua.edu.cn/git/nixpkgs.git";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.${system}.default = pkgs.mkShell {
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
          mkdir -p "$PWD/.config"
          export OPENCODE_CONFIG_DIR="$PWD/.config"
          # opencode data directory
	        mkdir -p "$PWD/.data" "$HOME/.local/share"
          ln -sfnT "$PWD/.data" "$HOME/.local/share/opencode"
        '';
      };
    };
}
