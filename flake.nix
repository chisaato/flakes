{
  description = "Home Manager configuration of gzzchh";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";

    # 添加你的自定义 flake
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      flake-utils,
      self,
      ...
    }@inputs:
    let
      inherit (nixpkgs) lib;
      inherit (flake-utils.lib) eachDefaultSystem mkApp;
      systems = flake-utils.lib.system;
      myPkgs = import ./packages;
      system = "x86_64-linux";
      
      # 动态获取当前用户名和Home目录
      # 注意：使用此配置需要加上 --impure 参数
      # 例如：home-manager switch --flake . --impure
      rawUsername = builtins.getEnv "USER";
      rawHomeDirectory = builtins.getEnv "HOME";
      
      # 如果在 Pure 模式下（无法获取环境变量），提供一个默认值以防报错
      username = if rawUsername != "" then rawUsername else "gzzchh";
      homeDirectory = if rawHomeDirectory != "" then rawHomeDirectory else "/home/gzzchh";

    in
    eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      rec {
        # packages = platformPackages;
        # checks = platformPackages;
      }
    )
    // {
      overlays = myPkgs.overlays;
      
      homeConfigurations."${username}" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [
            self.overlays.default
          ];
        };

        # 传递 username 和 homeDirectory 到 home.nix
        extraSpecialArgs = { inherit username homeDirectory; };

        modules = [ ./home.nix ];
      };
    };
}
