{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.my.golang.enable = lib.mkEnableOption "Go development tools";

  config = lib.mkIf config.my.golang.enable {
    home.packages = with pkgs; [
      go
      golangci-lint
      golangci-lint-langserver
      ko
      operator-sdk
    ];
  };
}
