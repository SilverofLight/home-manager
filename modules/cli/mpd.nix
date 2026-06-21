{ pkgs, ... }:

{
  home.packages = with pkgs; [
    mpd
  ];

  home.file.".mpd/mpd.conf".source =
    ../../dotfiles/mpd/mpd.conf;

  systemd.user.services.mpd = {
    Unit = {
      Description = "Music Player Daemon";
      Documentation = [
        "man:mpd(1)"
        "man:mpd.conf(5)"
      ];
      After = [ "default.target" ];
    };

    Service = {
      Type = "notify";

      ExecStart = "${pkgs.mpd}/bin/mpd --no-daemon";

      # 现代 systemd user 环境一般不需要 systemd mode
      Restart = "on-failure";

      # 性能/权限限制（用户级可以保留部分）
      LimitRTPRIO = 40;
      LimitRTTIME = "infinity";
      LimitMEMLOCK = "64M";

      # sandbox（用户级可用但要适当收敛）
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = true;

      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
      ];
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
