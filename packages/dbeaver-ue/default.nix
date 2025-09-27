{
  stdenv,
  fetchurl,
  lib,
  nix-update-script,
  makeWrapper,
  jdk,

}:

stdenv.mkDerivation rec {
  name = "dbeaver-ue";
  version = "25.2.0";
  agentUrl = "https://storage-common.misakacloud.dev/assets/dbeaver-agent.jar";
  src = fetchurl {
    url = "https://dbeaver.com/files/${version}/dbeaver-ee-${version}-linux.gtk.x86_64-nojdk.tar.gz";
    sha256 = "06cyc6scbmpb5w1xca216z8745yg7r64q70vpqsayly5gnxbra2a";
  };
  agentSrc = fetchurl {
    url = agentUrl;
    sha256 = "sha256-/t3lLKCJceF6YCWn9XrboXCdX8VNMgAiDa0XpA0F1a0=";
  };
  sourceRoot = "dbeaver";
  nativeBuildInputs = [ makeWrapper ];
  passthru.updateScript = nix-update-script { };

  installPhase = ''
    mkdir -p $out/share/dbeaver
    cp -r . $out/share/dbeaver
    cp $agentSrc $out/share/dbeaver/dbeaver-agent.jar
    echo "-javaagent:dbeaver-agent.jar" >> $out/share/dbeaver/dbeaver.ini
    mkdir -p $out/share/applications
    sed "s|/usr/share/dbeaver-ee/|$out/share/dbeaver/|g" dbeaver-ee.desktop > $out/share/applications/dbeaver-ee.desktop
    mkdir -p $out/bin
    makeWrapper $out/share/dbeaver/dbeaver $out/bin/dbeaver \
      --prefix PATH : ${jdk}/bin \
      --set JAVA_HOME ${jdk}/lib/openjdk
  '';

  meta = with lib; {
    description = "Universal Database Tool";
    homepage = "https://dbeaver.com/";
    license = licenses.asl20;
    platforms = platforms.linux;
  };
}
