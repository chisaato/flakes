rec {
  # 导入所有 overlay 目录
  sourcegit = import ./sourcegit;
  cosign = import ./cosign;

  # 这里可以添加更多 overlays，例如：
  # myoverlay = import ./myoverlay;

  # 默认 overlay，组合所有 overlays
  default = final: prev:
    let
      overlays = [
        sourcegit
        cosign
        # 添加更多 overlays 到这个列表，例如：
        # myoverlay
      ];
    in
    builtins.foldl' (acc: overlay: acc // (overlay final prev)) {} overlays;
}