{ pkgs, ... }:

{
  home.packages = [
    (pkgs.callPackage ../../pkgs/kd.nix {})
  ];

  systemd.user.services.kd = {
    Unit = {
      Description = "kd the command-line dictionary's server";
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.callPackage ../../pkgs/kd.nix {}}/bin/kd --server --log-to-stream";
      Restart = "always";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
