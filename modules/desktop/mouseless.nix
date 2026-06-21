{ stdenvNoCC, fetchurl }:

stdenvNoCC.mkDerivation {
  pname = "mouseless";
  version = "0.1.0";

  src = fetchurl {
    url = "https://github.com/jbensmann/mouseless/releases/download/v0.3.0/mouseless_linux_amd64.tar.gz";
    hash = "sha256:dc8db4d9badcea02a3393340065754d24eb8350f45d774be74ec0eda7ca4c6e0";
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    install -Dm755 $src $out/bin/mouseless
  '';
}
