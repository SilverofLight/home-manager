{ stdenvNoCC, fetchurl }:

stdenvNoCC.mkDerivation {
  pname = "kd";
  version = "latest";

  src = fetchurl {
    url = "https://github.com/Karmenzind/kd/releases/latest/download/kd_linux_amd64";
    sha256 = "sha256:ee890e5ef6aa86d1b5157654c8ed113e386f4eb4b563c6f13f49fb9c162474ef";
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/kd
    chmod +x $out/bin/kd
  '';
}
