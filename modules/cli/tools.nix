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
  ];
}
