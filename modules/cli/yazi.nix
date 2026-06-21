{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    (yazi.override {
        _7zz = _7zz-rar;
    })
    ffmpeg
    poppler
    fd
    ripgrep
    jq
    fzf
    zoxide
    resvg
    imagemagick
  ];

  home.activation.linkYaziDotfiles = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ln -sfT $HOME/.config/home-manager/dotfiles/yazi $HOME/.config/yazi
    echo "[OK] link yazi dotfiles successfully"
  '';
}
