{ lib, ... }:

{
  home.activation.linkBookmarksDB = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ln -sfT $HOME/.config/home-manager/dotfiles/bookmarks.db $HOME/.cache/bookmarks.db
    echo "[OK] link dotfiles successfully"
  '';
}
