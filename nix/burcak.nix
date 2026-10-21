{ lib, pkgs, ... }:
let
  # Burçak'ın müzik servisi: tür (çalar → MusicBrainz), tempo (ses çıkışı zarfı) ve video tespiti.
  muzik = pkgs.writeShellScriptBin "burcak-muzik" ''
    export PATH="${lib.makeBinPath [ pkgs.playerctl pkgs.pulseaudio ]}:$PATH"
    exec ${pkgs.python3}/bin/python3 -I ${./burcak}/burcak_muzik.py "$@"
  '';
in {
  home.packages = [ muzik ];
}
