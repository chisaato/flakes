final: prev: {
  sourcegit = prev.sourcegit.overrideAttrs (oldAttrs: {
    preInstall = oldAttrs.preInstall + ''
      makeWrapperArgs+=(
        --set GTK_IM_MODULE fcitx
        --set QT_IM_MODULE fcitx
        --set XMODIFIERS @im=fcitx
      )
    '';
  });
}