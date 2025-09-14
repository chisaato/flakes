{
  description = "Home Manager configuration of gzzchh";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # 添加你的自定义 flake
    misakacloud-flake = {
      url = "github:chisaato/nur";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      misakacloud-flake,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true; # 允许非自由软件
          permittedInsecurePackages = [
            "python3.13-apache-airflow-2.7.3"
          ];

        };
        # overlays = [
        #   misakacloud-flake.overlays.default
        # ];
      };
    in
    {
      homeConfigurations."gzzchh" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        # pkgs = nixpkgs.legacyPackages.x86_64-linux;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        # extraSpecialArgs = {
        #   inherit misakacloud-flake;
        # };
        modules = [ ./home.nix ];
      };
    };
}
