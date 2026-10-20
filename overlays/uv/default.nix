final: prev: {
  uv = prev.symlinkJoin {
    name = "uv-${prev.uv.version}";
    paths = [ prev.uv ];
    nativeBuildInputs = [ prev.makeWrapper ];
    postBuild = ''
      rm $out/bin/uv
      [ -e $out/bin/uvx ] && rm $out/bin/uvx

      WRAPPER_RUN='
        if [ -z "$UV_CACHE_DIR" ]; then
          _cur="$PWD"
          _cur_dev=$(stat -c %d "$_cur" 2>/dev/null)
          if [ -n "$_cur_dev" ]; then
            while [ "$_cur" != "/" ]; do
              _parent=$(dirname "$_cur")
              _parent_dev=$(stat -c %d "$_parent" 2>/dev/null)
              if [ "$_parent_dev" != "$_cur_dev" ]; then
                break
              fi
              _cur="$_parent"
            done
            if [ "$_cur" != "/" ]; then
              export UV_CACHE_DIR="$_cur/.cache/uv"
            fi
          fi
        fi
      '

      makeWrapper ${prev.uv}/bin/uv $out/bin/uv \
        --run "$WRAPPER_RUN"

      if [ -e ${prev.uv}/bin/uvx ]; then
        makeWrapper ${prev.uv}/bin/uvx $out/bin/uvx \
          --run "$WRAPPER_RUN"
      fi
    '';
  };
}
