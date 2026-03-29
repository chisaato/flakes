{
  stdenv,
  fetchurl,
  lib,
  nix-update-script,
}:

let
  version = "1.18.1";

  sources = {
    "x86_64-linux" = {
      url = "https://github.com/avisi-cloud/acloud-toolkit/releases/download/v${version}/acloud-toolkit_${version}_linux_amd64.tar.gz";
      hash = "sha256-9d66ydANLt0sk90B40QULFrVfuKVULqTYVf18MViF/M=";
    };
    "aarch64-linux" = {
      url = "https://github.com/avisi-cloud/acloud-toolkit/releases/download/v${version}/acloud-toolkit_${version}_linux_arm64.tar.gz";
      hash = "sha256-INMFO8XQVthgFq+lsHI2t0Me5eSJHnmInNIyM/PRpwM=";
    };
    "x86_64-darwin" = {
      url = "https://github.com/avisi-cloud/acloud-toolkit/releases/download/v${version}/acloud-toolkit_${version}_darwin_amd64.tar.gz";
      hash = "sha256-NLjT8JcE7b3Hiq0+GRpjW8Mr5uYlmsQMnSiXZlymosQ=";
    };
    "aarch64-darwin" = {
      url = "https://github.com/avisi-cloud/acloud-toolkit/releases/download/v${version}/acloud-toolkit_${version}_darwin_arm64.tar.gz";
      hash = "sha256-rpK4AeJr5qKFjYcARSEL0DHvrotwJbH0HUkDp+91J+8=";
    };
  };

  src = sources.${stdenv.hostPlatform.system} or (throw "acloud-toolkit-bin: unsupported platform ${stdenv.hostPlatform.system}");
in

stdenv.mkDerivation {
  pname = "acloud-toolkit-bin";
  inherit version;

  src = fetchurl {
    inherit (src) url hash;
  };

  sourceRoot = ".";

  passthru.updateScript = nix-update-script { };

  installPhase = ''
    mkdir -p $out/bin
    cp acloud-toolkit $out/bin/
    chmod +x $out/bin/acloud-toolkit
  '';

  meta = with lib; {
    description = "A CLI tool to aid in the automation of common and repetitive Kubernetes tasks";
    longDescription = ''
      acloud-toolkit is a powerful CLI for Kubernetes automation, specializing in:
      - CSI snapshot management (create, restore, import, list)
      - Volume migration between storage classes
      - Volume synchronization between persistent volumes
      - Persistent volume resizing
      - Orphaned volumes and snapshots cleanup
    '';
    homepage = "https://github.com/avisi-cloud/acloud-toolkit";
    license = licenses.asl20;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    mainProgram = "acloud-toolkit";
  };
}
