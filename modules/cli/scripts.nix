{ lib, ... }:

{
    home.activation.linkScripts = lib.hm.dag.entryAfter ["writeBoundary"] ''
        ln -sfT $HOME/.config/home-manager/dotfiles/scripts/ $HOME/.scripts

        ln -sfT $HOME/.config/home-manager/dotfiles/scripts/bookmarks.py $HOME/.local/bin/bookmarks
        ln -sfT $HOME/.config/home-manager/dotfiles/scripts/bw-create.py $HOME/.local/bin/bw-create.py
        ln -sfT $HOME/.config/home-manager/dotfiles/scripts/bw-export.sh $HOME/.local/bin/bw-export.sh
        ln -sfT $HOME/.config/home-manager/dotfiles/scripts/checkKernels.sh $HOME/.local/bin/checkKernels
        ln -sfT $HOME/.config/home-manager/dotfiles/scripts/dl-openlist.sh $HOME/.local/bin/dl-openlist
        ln -sfT $HOME/.config/home-manager/dotfiles/scripts/kd.sh $HOME/.local/bin/kd.sh
        ln -sfT $HOME/.config/home-manager/dotfiles/scripts/miao.py $HOME/.local/bin/miao.py
        ln -sfT $HOME/.config/home-manager/dotfiles/scripts/mpvh.py $HOME/.local/bin/mpvh
        ln -sfT $HOME/.config/home-manager/dotfiles/scripts/obsx $HOME/.local/bin/obsx
        ln -sfT $HOME/.config/home-manager/dotfiles/scripts/pinme.py $HOME/.local/bin/pinme
        ln -sfT $HOME/.config/home-manager/dotfiles/scripts/pls.py $HOME/.local/bin/pls
        ln -sfT $HOME/.config/home-manager/dotfiles/scripts/startw $HOME/.local/bin/startw
        ln -sfT $HOME/.config/home-manager/dotfiles/scripts/wallpaper.sh $HOME/.local/bin/wallpaper.sh
        ln -sfT $HOME/.config/home-manager/dotfiles/scripts/wallpaperb.sh $HOME/.local/bin/wallpaperb.sh
        echo "[OK] link scripts successfully"
    '';
}
