{
  lib,
  stdenvNoCC,
  fetchurl,
  undmg,
  makeWrapper,
  openjdk21,
  gnused,
  autoPatchelfHook,
  autoSignDarwinBinariesHook,
  wrapGAppsHook3,
  gtk3,
  glib,
  webkitgtk_4_1,
  glib-networking,
  override_xmx ? "1024m",
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "dbeaver-ue-bin";
  version = "26.0.0";
  agentUrl = "https://storage-common.misakacloud.dev/assets/dbeaver-agent.jar";

  src =
    let
      inherit (stdenvNoCC.hostPlatform) system;
      selectSystem = attrs: attrs.${system} or (throw "Unsupported system: ${system}");
      suffix = selectSystem {
        x86_64-linux = "linux-x86_64.tar.gz";
        # aarch64-linux = "linux-aarch64.tar.gz";
        # x86_64-darwin = "macos-x86_64.dmg";
        # aarch64-darwin = "macos-aarch64.dmg";
      };
      hash = selectSystem {
        x86_64-linux = "sha256-fjBAgL9q2eTfGf0BBp5dtFgvq6q+cmfPPbTG9VZmne0=";
        # aarch64-linux = "sha256-+byvDpqaijxt0LnGJuWg1ooVnb1bLdaFfvEmlaEmBCA=";
        # x86_64-darwin = "sha256-59mrDs00XxIjfiqm3OsoHqbuNQI3VdB1ff3l/51lzEg=";
        # aarch64-darwin = "sha256-jUWZr5DwUv6aFfGEox62r+PRoEqZIvdP6YHCsWshYJA=";
      };
    in
    fetchurl {
      url = "https://c.scgit.top/downloads.dbeaver.net/ultimate/${finalAttrs.version}/dbeaver-ue-${finalAttrs.version}-${suffix}";
      inherit hash;
    };

  agentSrc = fetchurl {
    url = finalAttrs.agentUrl;
    sha256 = "sha256-/5Z9tmkqT+dsfnMXhHnvIO3Bq2LnPCdXXNtBqeqP54A=";
  };

  sourceRoot = lib.optional stdenvNoCC.hostPlatform.isDarwin "DBeaver.app";

  nativeBuildInputs = [
    makeWrapper
  ]
  ++ lib.optionals (!stdenvNoCC.hostPlatform.isDarwin) [
    gnused
    wrapGAppsHook3
    autoPatchelfHook
  ]
  ++ lib.optionals stdenvNoCC.hostPlatform.isDarwin [
    undmg
    autoSignDarwinBinariesHook
  ];

  dontConfigure = true;
  dontBuild = true;

  # 在 macOS 上的,我们先不要
  # prePatch = ''
  #   substituteInPlace ${lib.optionalString stdenvNoCC.hostPlatform.isDarwin "Contents/Eclipse/"}dbeaver.ini \
  #     --replace-fail '-Xmx1024m' '-Xmx${override_xmx}'
  # ''
  # # remove the bundled JRE configuration on Darwin
  # # dont use substituteInPlace here because it would match "-vmargs"
  # + lib.optionalString stdenvNoCC.hostPlatform.isDarwin ''
  #   sed -i -e '/^-vm$/ { N; d; }' Contents/Eclipse/dbeaver.ini
  # '';

  preInstall = ''
    # most directories are for different architectures, only keep what we need
    shopt -s extglob
    pushd ${lib.optionalString stdenvNoCC.hostPlatform.isDarwin "Contents/Eclipse/"}plugins/com.sun.jna_*/com/sun/jna/
    rm -r !(ptr|internal|linux-x86-64|linux-aarch64|darwin-x86-64|darwin-aarch64)/
    popd

    # remove the bundled JRE
    rm -rf ${lib.optionalString stdenvNoCC.hostPlatform.isDarwin "Contents/Eclipse/"}jre/
  '';

  installPhase =
    if !stdenvNoCC.hostPlatform.isDarwin then
      ''
        runHook preInstall



        mkdir -p $out/opt/dbeaver-ue $out/bin
        cp -r * $out/opt/dbeaver-ue
        # 拷贝 agent
        cp $agentSrc $out/opt/dbeaver-ue/dbeaver-agent.jar
        # 写参数
        echo "-javaagent:$out/opt/dbeaver-ue/dbeaver-agent.jar" >> $out/opt/dbeaver-ue/dbeaver.ini

        makeWrapper $out/opt/dbeaver-ue/dbeaver $out/bin/dbeaver-ue \
          --prefix PATH : "${openjdk21}/bin" \
          --set JAVA_HOME "${openjdk21.home}" \
          --prefix GIO_EXTRA_MODULES : "${glib-networking}/lib/gio/modules" \
          --prefix LD_LIBRARY_PATH : "$out/lib:${
            lib.makeLibraryPath [
              gtk3
              glib
              webkitgtk_4_1
              glib-networking
            ]
          }"

        mkdir -p $out/share/icons/hicolor/256x256/apps
        ln -s $out/opt/dbeaver-ue/dbeaver.png $out/share/icons/hicolor/256x256/apps/dbeaver-ue.png

        mkdir -p $out/share/applications
        ln -s $out/opt/dbeaver-ue/dbeaver-ue.desktop $out/share/applications/dbeaver-ue.desktop

        substituteInPlace $out/opt/dbeaver-ue/dbeaver-ue.desktop \
          --replace-fail "/usr/share/dbeaver-ue/dbeaver.png" "dbeaver-ue" \
          --replace-fail "/usr/share/dbeaver-ue/dbeaver" "$out/bin/dbeaver-ue"

        sed -i '/^Path=/d' $out/share/applications/dbeaver-ue.desktop

        runHook postInstall
      ''
    else
      ''
        runHook preInstall

        mkdir -p $out/{Applications/dbeaver.app,bin}
        cp -R . $out/Applications/dbeaver.app
        wrapProgram $out/Applications/dbeaver.app/Contents/MacOS/dbeaver \
          --prefix PATH : "${openjdk21}/bin" \
          --set JAVA_HOME "${openjdk21.home}"
        makeWrapper $out/{Applications/dbeaver.app/Contents/MacOS/dbeaver,bin/dbeaver}

        runHook postInstall
      '';

  passthru.updateScript = ./update.sh;

  meta = {
    homepage = "https://dbeaver.io/";
    changelog = "https://github.com/dbeaver/dbeaver/releases/tag/${finalAttrs.version}";
    description = "Universal SQL Client for developers, DBA and analysts. Supports MySQL, PostgreSQL, MariaDB, SQLite, and more";
    longDescription = ''
      Free multi-platform database tool for developers, SQL programmers, database
      administrators and analysts. Supports all popular databases: MySQL,
      PostgreSQL, MariaDB, SQLite, Oracle, DB2, SQL Server, Sybase, MS Access,
      Teradata, Firebird, Derby, etc.
    '';
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.asl20;
    platforms = with lib.platforms; linux ++ darwin;
    maintainers = with lib.maintainers; [
      gepbird
      mkg20001
      yzx9
    ];
    mainProgram = "dbeaver-ue";
  };
})
