{
  config,
  pkgs,
  ...
}:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "gzzchh";
  home.homeDirectory = "/home/gzzchh";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    argocd
    buildkit
    bun
    chart-testing
    chezmoi
    cilium-cli
    cosign
    crc
    ddev
    direnv
    dotnet-sdk_9
    etcd
    gdu
    gemini-cli
    gh
    go

    golangci-lint
    golangci-lint-langserver
    helm-ls
    hubble
    istioctl
    kind
    ko
    kubectl
    kubernetes-helm
    kyverno-chainsaw
    libyaml
    minikube
    nix
    nixfmt
    nodejs
    openbao
    opentofu
    operator-sdk
    payload-dumper-go
    pixi
    pnpm
    q
    rclone
    skopeo
    step-ca
    step-cli
    terragrunt
    uv
    velero
    wgcf
    wireproxy
    yarn-berry
    yq-go
    ruby
    devbox
    age
    age-plugin-yubikey
    kn
    func
    sops
    caddy
    niv
    kubevela
    yaml-language-server
    openapi-generator-cli
    skaffold
    telepresence2
    chart-testing
    openbao
    step-ca
    tokei
    act
    fnm

    # renderdoc

    # 打包辅助工具
    nixpkgs-vet
    nixpkgs-fmt
    nixpkgs-lint
    nix-update

    # 图形化应用
    feishu
    sourcegit
    # avalonia-ilspy

    # 自己打包的
    # garden-bin
    dbeaver-ue-bin
    dbeaver-te-bin
    chart-releaser

  ];

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
    DOTNET_ROOT = "${pkgs.dotnet-sdk_9}/share/dotnet/";
    TEST_ENV_DEBUG = "true";
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
