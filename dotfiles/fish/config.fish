if status is-interactive
    # Commands to run in interactive sessions can go here
    # deepseek key
    # set -l deep_key $(cat $HOME/Documents/keys/deepseek_key)
    # export DEEPSEEK_API_KEY=$deep_key
    # set -l groq_key $(cat $HOME/Documents/keys/groq_key)
    # export GROQ_API_KEY=$groq_key
    # set -l gemini_key $(cat $HOME/Documents/keys/GEMINI_API)
    # export GEMINI_API_KEY=$gemini_key
    # set -l qwen $(cat $HOME/Documents/keys/qwen_key)
    # export QWEN_API_KEY=$qwen
    # export DASHSCOPE_API_KEY=$qwen
    #
    # export CLASH_PASSWORD=$(cat $HOME/Documents/keys/mihomo_select)
    # export BOOKMARKS_KEY=$(cat $HOME/Documents/keys/bookmarks_key)

    source $HOME/Documents/keys/api_keys.fish
    export BW_SESSION=$(cat $HOME/Documents/keys/bitwarden)

    set -U fish_user_paths $HOME/.local/bin $fish_user_paths
    # set -U fish_user_paths /opt/anaconda/bin $fish_user_paths

    # 解决 conda 报错
    # set -gx OPENSSL_MODULES /opt/anaconda/lib/ossl-modules

    if not contains "$HOME/.nix-profile/share" $XDG_DATA_DIRS
        set -gx XDG_DATA_DIRS $HOME/.nix-profile/share $XDG_DATA_DIRS
    end

    function ra
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        set cwd (cat "$tmp")
        if test -n "$cwd" -a "$cwd" != "$PWD"
            builtin cd "$cwd"
        end
        rm -f "$tmp"
    end

    alias ls="eza --icons"
    alias ll="eza --icons -l"
    alias la="eza --icons -a"
    alias lla="eza --icons -la"
    alias v="nvim"
    alias wifils="nmcli device wifi list"
    alias wificnn="nmcli device wifi connect"
    alias hmm="h-m-m"
    alias gi="lazygit"
    alias t="tmux"
    alias ta="tmux attach"
    alias tn="tmux new -s"
    alias tt="tmux attach -t"
    alias en="~/.scripts/touchEtyma.sh"
    alias link="scrcpy"
    # alias s="fastfetch"
    alias hibernate="systemctl hibernate"
    alias conda="micromamba"

    function s
        if set -q SSH_CONNECTION
            fastfetch -c ~/.config/fastfetch/config2.jsonc
        else
            fastfetch
        end
    end

    if test "$TERM" = xterm-kitty
        function ssh
            kitty +kitten ssh $argv
        end
    end

    set -gx EDITOR nvim
    set -gx fish_greeting ''

    # 设置 FZF 的配置
    set -gx FZF_DEFAULT_OPTS '--height 40% --reverse --preview "cat {}"'

    # 为 Fish shell 配置 FZF 的命令补全
    set -g __fzf_fish_path $HOME/.fzf/bin
    set -gx PATH $PATH $HOME/.fzf/bin

    # FZF 绑定命令到 Ctrl-T 和 Ctrl-R
    function fzf-file-widget
        commandline -i (fzf)
    end
    function fzf-history-widget
        commandline -i (history | fzf)
    end

    bind ctrl-c cancel-commandline

    # # vi mode
    # set -g fish_bind_mode fish_vi_key_bindings
    #
    # # 绑定快捷键
    # function fish_user_key_bindings
    #     bind -M insert \ct fzf-file-widget # Ctrl-T
    #     bind -M insert \cr fzf-history-widget # Ctrl-R
    #     # bind -M insert jk 'if commandline -P; commandline -f cancel; else; set fish_bind_mode default; commandline -f backward-char repaint-mode; end'
    #     bind -M insert \cf forward-char
    #     bind -M insert \ca beginning-of-line
    #     bind -M insert \ce end-of-line
    #     bind -M default " "a beginning-of-line
    #     bind -M default " "e end-of-line
    #     bind -M default i forward-char
    #     bind -M default l undo
    #     bind -m insert u 'set fish_cursor_end_mode exclusive' repaint-mode
    #     bind -M insert ctrl-c cancel-commandline
    #     bind -M default e up-or-search
    #     bind -M default n down-or-search
    # end
end

# opencode
fish_add_path /home/silver/.opencode/bin

# nix
fish_add_path /home/silver/.nix-profile/bin

# >>> mamba initialize >>>
# !! Contents within this block are managed by '.mamba-wrapped shell init' !!
# set -gx MAMBA_EXE "/nix/store/v1nckrw66v5098m3nbs9r0y16djbfxaz-mamba-cpp-2.6.2/bin/.mamba-wrapped"
set -gx MAMBA_ROOT_PREFIX "/home/silver/.conda"
# $MAMBA_EXE shell hook --shell fish --root-prefix $MAMBA_ROOT_PREFIX | source
source (micromamba shell hook --shell fish | psub)
# <<< mamba initialize <<<
