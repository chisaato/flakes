final: prev: {
  cosign = prev.cosign.overrideAttrs (oldAttrs: {
    doCheck = false;
  });
}
