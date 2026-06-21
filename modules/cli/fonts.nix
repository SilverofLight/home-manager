{ pkgs, ... }:

{
    home.packages = with pkgs; [
        jetbrains-mono
        font-awesome
        texlivePackages.opensans
    ];
}
