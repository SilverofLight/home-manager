{ pkgs, ... }:

{
  home.packages = with pkgs; [
    mpd
  ];

  home.file.".mpd/mpd.conf".source =
    ../../dotfiles/mpd/mpd.conf;
}
