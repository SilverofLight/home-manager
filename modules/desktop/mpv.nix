{ pkgs, ... }:

{
  home.packages = with pkgs; [
    mpv
  ];
  home.file.".config/mpv".source =
    ../../dotfiles/mpv;
}
