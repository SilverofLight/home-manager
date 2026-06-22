{ lib, ... }:

{
    # 系统安装
    home.activation.linkFcitx5AndRimeDotfiles = lib.hm.dag.entryAfter ["writeBound"] ''
        ln -sfT $HOME/.config/home-manager/dotfiles/fcitx5/.config/fcitx5/ $HOME/.config/fcitx5
        ln -sfT $HOME/.config/home-manager/dotfiles/fcitx5/.local/share/fcitx5/ $HOME/.local/share/fcitx5
    '';
}
