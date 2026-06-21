{ pkgs, ... }:

{
  home.packages = with pkgs; [

    fd
    fzf

    jq
    yq

    tree
    bat
    eza

    wget
    curl

    unzip
    zip

    btop
    rclone
    micromamba
    nodejs
    stow
    awww
    blueman
    bluez
    calc
    cliphist
    kdePackages.dolphin

    isync
    lazygit

    mutt
    ncdu

    translate-shell

    ttyper
    udiskie
    w3m
    wf-recorder

    yt-dlp
  ];
}
