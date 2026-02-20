{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.my.nix-tools.enable = lib.mkEnableOption "Nix development tools" // {
    default = true;
  };

  config = lib.mkIf config.my.nix-tools.enable {
    home.packages = with pkgs; [
      nix
      nixfmt
      nixpkgs-vet
      nixpkgs-fmt
      nixpkgs-lint
      nix-update
      niv
      direnv
    ];
  };
}
