{
  config,
  lib,
  pkgs,
  isDarwin,
  ...
}:
{
  config = lib.mkIf config.custom.shell.enable {
    programs.zsh = {
      enable = true;

      # Keep $HOME clean: all zsh dotfiles live under ~/.config/zsh. HM still
      # writes a one-line ~/.zshenv stub that sources this dir — unavoidable,
      # since zsh always reads ~/.zshenv before it knows about ZDOTDIR.
      dotDir = "${config.xdg.configHome}/zsh";

      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      # bindkey -e
      defaultKeymap = "emacs";

      history = {
        size = 5000;
        save = 5000;
        share = true;
        ignoreDups = true;
        ignoreAllDups = true;
        ignoreSpace = true;
        saveNoDups = true;
        findNoDups = true;
        path = "${config.xdg.dataHome}/zsh/history";
      };

      # OMZ snippets that used to be pulled in via zinit; Nix owns them now.
      oh-my-zsh = {
        enable = true;
        plugins = [
          "aws"
          "kubectl"
          "kubectx"
          "command-not-found"
          "colored-man-pages"
          "colorize"
        ];
      };

      # fzf-tab must load after compinit; the package ships the plugin file.
      plugins = [
        {
          name = "fzf-tab";
          src = pkgs.zsh-fzf-tab;
          file = "share/fzf-tab/fzf-tab.plugin.zsh";
        }
      ];

      sessionVariables = {
        # oh-my-zsh runs compinit itself and only honors a pre-set ZSH_COMPDUMP;
        # point it at XDG cache so no .zcompdump lands in ~/.config/zsh. The rest
        # of the env (EDITOR, GOPATH, MANWIDTH, LESSOPEN, DIARKIS_PATH) is shell-
        # agnostic and lives in profiles/home/base.nix's home.sessionVariables.
        ZSH_COMPDUMP = "${config.xdg.cacheHome}/zsh/zcompdump";
      };

      shellAliases = {
        # k8s family
        k = "kubectl";
        kctx = "kubectx";
        kns = "kubens";

        # mise / go / git
        mr = "mise run";
        glci = "golangci-lint run ./...";
        gcnv = "git commit --no-verify -m";
        lg = "lazygit";

        # gcloud family
        gclist = "gcloud config configurations list";
        gcact = "gcloud config configuration activate";

        e = "$EDITOR";
        c = "clear";
        vim = "nvim";
        ls = "ls --color";
        nvimc = "$EDITOR ~/.config/nvim/init.lua";

        # ~/.bin helper scripts
        td = "~/.bin/t_diarkis.sh";
        buildd = "~/.bin/build_server.sh";
        killd = "~/.bin/kill_diarkis.sh";
        buildlocal = "~/.bin/build_server_local.sh";
        worktree = "~/.bin/worktree.sh";
        go-scrape = "~/.bin/go-scrape2.sh";
        scrape = "~/.bin/scrape.sh";
      };

      # SHELL_SESSIONS_DISABLE must be set in .zshenv (not .zshrc) so it lands
      # before macOS's /etc/zshrc_Apple_Terminal registers its session hooks,
      # which is what would otherwise create ~/.zsh_sessions. (PATH — incl.
      # .cargo/bin — comes from home.sessionPath in profiles/home/base.nix.)
      envExtra = ''
        export SHELL_SESSIONS_DISABLE=1
      '';

      # Interactive-shell setup: completion styling, keybindings, mise.
      initContent = ''
        bindkey '^p' history-search-backward
        bindkey '^n' history-search-forward

        zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
        zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
        zstyle ':completion:*' menu no
        zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
        zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

        eval "$(mise activate zsh)"
      '';

      # Login-shell env, mirrors the fish module's loginShellInit.
      profileExtra = ''
        ${lib.optionalString isDarwin ''eval "$(/opt/homebrew/bin/brew shellenv)"''}

        # OrbStack CLI integration. macOS-only, but already silent on absence.
        source ~/.orbstack/shell/init.zsh 2>/dev/null || :

        if [ -f "$HOME/.local/share/google-cloud-sdk/path.zsh.inc" ]; then
          . "$HOME/.local/share/google-cloud-sdk/path.zsh.inc"
        fi
        if [ -f "$HOME/.local/share/google-cloud-sdk/completion.zsh.inc" ]; then
          . "$HOME/.local/share/google-cloud-sdk/completion.zsh.inc"
        fi
      '';
    };

    # compinit -d won't create its parent; make sure the cache dir exists.
    home.file."${config.xdg.cacheHome}/zsh/.keep".text = "";

    # On darwin, nix-darwin's /etc/zshenv exports ZDOTDIR (programs.zsh.shellInit),
    # so zsh reads ~/.config/zsh directly and the ~/.zshenv bootstrap stub HM
    # writes for dotDir is dead weight — drop it. Linux hosts keep the stub until
    # their system layer sets ZDOTDIR too.
    home.file.".zshenv".enable = lib.mkIf isDarwin (lib.mkForce false);
  };
}
