{ config, pkgs, nixGL, ... }:

{
  home.username = "silver";
  home.homeDirectory = "/home/silver";
  targets.genericLinux.gpu.enable = true;

  home.stateVersion = "25.05";

  imports = [
    ./modules/cli/git.nix
    ./modules/cli/fish.nix
    ./modules/cli/tools.nix
    ./modules/cli/dunst.nix
    ./modules/cli/fastfetch.nix
    ./modules/cli/tmux.nix
    ./modules/cli/mpd.nix

    ./modules/dev/neovim.nix

    ./modules/desktop/mpv.nix
    ./modules/desktop/qutebrowser.nix
    ./modules/desktop/hyprland.nix
    ./modules/desktop/niri.nix
    ./modules/desktop/waybar.nix
    ./modules/desktop/kitty.nix
    ./modules/desktop/swaylock.nix
    ./modules/desktop/wofi.nix
    ./modules/desktop/wlogout.nix
    ./modules/desktop/wallpaper.nix
    {pkgs.callPackage ./modules/desktop/mouseless.nix {}}
  ];

  programs.home-manager.enable = true;
}
