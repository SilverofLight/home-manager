{ pkgs, ... }:

{
  home.packages = with pkgs; [
    wl-kbptr
  ];

  home.file.".config/wl-kbptr".source =
    ../../dotfiles/wl-kbptr;
}
