{
  pkgs,
  inputs ? null,
  filterByPlatform ? false,
}:
let
  inherit (pkgs) lib system;
  utils = import ../utils;
  callPackage = pkgs.newScope (
    self
    // {
      sources = callPackage ./_sources/generated.nix { };
    }
  );
  self = self_base;

  self_base = {
    garden-bin = callPackage ./garden-bin { };
    dbeaver-ue-bin = callPackage ./dbeaver-ue-bin { inherit (pkgs) autoSignDarwinBinariesHook; };
    dbeaver-te-bin = callPackage ./dbeaver-te-bin { inherit (pkgs) autoSignDarwinBinariesHook; };
    chart-releaser = callPackage ./chart-releaser { };
    acloud-toolkit-bin = callPackage ./acloud-toolkit-bin { };
  };

in
if filterByPlatform then
  pkgs.lib.filterAttrs (n: v: utils.checkPlatform pkgs.system v) self
else
  self
