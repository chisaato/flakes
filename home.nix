{
  config,
  pkgs,
  username,
  homeDirectory,
  ...
}:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = username;
  home.homeDirectory = homeDirectory;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  # 导入模块
  imports = [
    ./modules/nix-tools.nix
    ./modules/misc.nix
    ./modules/kubernetes.nix
    ./modules/golang.nix
    ./modules/nodejs.nix
    ./modules/cloud-native.nix
    ./modules/container.nix
    ./modules/desktop.nix
  ];

  # 模块开关配置
  # 默认启用的模块：nix-tools, misc
  # 按需启用的模块：kubernetes, golang, nodejs, cloud-native, container, desktop
  my = {
    kubernetes.enable = true;
    golang.enable = true;
    nodejs.enable = true;
    cloud-native.enable = true;
    container.enable = true;
    desktop.enable = true;
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;
    #
    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/gzzchh/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
    # DOTNET_ROOT = "${pkgs.dotnet-sdk_9}/share/dotnet/";
    # TEST_ENV_DEBUG = "true";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  # 启用桌面集成
  xdg.enable = true;
  # 其他集成
  # programs.bash.enable = true;
  # programs.zsh.enable = true;
  # 不要来控制系统服务
  systemd.user.startServices = false;

}
