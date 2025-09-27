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

    in
    eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        # platformPackages = myPkgs.packages {
        #   inherit pkgs inputs;
        #   filterByPlatform = true;
        # };
      in
      rec {
        # packages = platformPackages;
        # checks = platformPackages;
      }
    )
    // {
      overlays = myPkgs.overlays;
      nixosModules = import ./modules;
      homeConfigurations."gzzchh" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [
            self.overlays.default
          ];
        };

        modules = [ ./home.nix ];
      };
    };
}
