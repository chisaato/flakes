{
  buildGoModule,
  coreutils,
  fetchFromGitHub,
  git,
  installShellFiles,
  kubectl,
  kubernetes-helm,
  lib,
  makeWrapper,
  yamale,
  yamllint,
}:

buildGoModule rec {
  pname = "chart-releaser";
  version = "1.8.1";

  src = fetchFromGitHub {
    owner = "helm";
    repo = "chart-releaser";
    rev = "v${version}";
    hash = "sha256-h1czHb/xK+kOEK4TJhMnwnLeVmQm52C8dTUy+fahJ90=";
  };

  vendorHash = "sha256-nUqUtm7SUKNEITzFJ4gozlegqGtyiRNGKDyOqteGYTw=";

  postPatch = ''
    substituteInPlace pkg/config/config.go \
      --replace "\"/etc/cr\"," "\"$out/etc/cr\","
  '';

  ldflags = [
    "-w"
    "-s"
    "-X github.com/helm/chart-releaser/v3/cr/cmd.Version=${version}"
    "-X github.com/helm/chart-releaser/v3/cr/cmd.GitCommit=${src.rev}"
    "-X github.com/helm/chart-releaser/v3/cr/cmd.BuildDate=19700101-00:00:00"
  ];

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
    git
  ];

  postInstall = ''

    installShellCompletion --cmd cr \
      --bash <($out/bin/cr completion bash) \
      --zsh <($out/bin/cr completion zsh) \
      --fish <($out/bin/cr completion fish) \

    wrapProgram $out/bin/cr --prefix PATH : ${
      lib.makeBinPath [
        coreutils
        git
        kubectl
        kubernetes-helm
        yamale
        yamllint
      ]
    }
  '';

  meta = with lib; {
    description = "Tool for releaser Helm charts";
    homepage = "https://github.com/helm/chart-releaser";
    license = licenses.asl20;
    maintainers = with maintainers; [ atkinschang ];
    mainProgram = "cr";
  };
}
