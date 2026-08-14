{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.my.nodejs.enable = lib.mkEnableOption "Node.js development tools";

  config = lib.mkIf config.my.nodejs.enable {
    home.packages = with pkgs; [
      # nodejs
      # node-gyp
      # pnpm
      # yarn-berry
      # bun
      fnm
    ];
  };
}
