rec {
  packages = import ./packages.nix;

  legacyPackages =
    pkgs:
    import ./packages.nix {
      inherit pkgs;
      filterByPlatform = false;
    };

  # 导入 overlays
  myOverlays = import ../overlays;

  overlays.default = final: prev:
    let
      packageOverlay = legacyPackages prev;
      overlayList = [
        (_: _: packageOverlay)  # 包装成函数
        myOverlays.default
      ];
    in
    builtins.foldl' (acc: overlay: acc // (overlay final prev)) {} overlayList;
}
