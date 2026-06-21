{ stdenvNoCC, fetchurl }:

stdenvNoCC.mkDerivation {
  pname = "mouseless";
  version = "0.3.0";

  src = fetchurl {
    url = "https://github.com/jbensmann/mouseless/releases/download/v0.3.0/mouseless_linux_amd64.tar.gz";
    hash = "sha256-3I202brc6gKjOTNABldU0k64NQ9F13S+dOwO2nykxuA=";
  };

  dontBuild = true;

  sourceRoot = ".";

  installPhase = ''
    ls -lah

    mkdir -p $out/bin
    install -Dm755 mouseless $out/bin/mouseless
  '';
}
