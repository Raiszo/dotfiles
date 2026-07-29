{ config, pkgs, lib, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "raiszo";
  home.homeDirectory = "/home/raiszo";

  targets.genericLinux.enable = true;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "26.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    cascadia-code
    awscli2
    fnm
    gnumake
    jq
    tree
    ripgrep

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';

    ".tmux.conf".source = tmux/tmux.conf;
  };

  xdg.configFile."nix" = {
    text = ''
      experimental-features = nix-command flakes
    '';
    target = "nix/nix.conf";
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/raiszo/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.emacs = {
    enable = true;
    package = pkgs.emacs30-pgtk;
    extraPackages = epkgs: [
      epkgs.vterm
      (epkgs.treesit-grammars.with-grammars (grammars: [ 
        grammars.tree-sitter-typescript
        grammars.tree-sitter-javascript
        grammars.tree-sitter-c
        grammars.tree-sitter-json
        grammars.tree-sitter-tsx
        grammars.tree-sitter-nix
        grammars.tree-sitter-dockerfile
        grammars.tree-sitter-python
        grammars.tree-sitter-elisp
        grammars.tree-sitter-org
      ]))
    ];
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    plugins = [
      {
        name = "modern-dark-pro-capsule";
        file = "modern-dark-pro-capsule.zsh-theme";
        src = pkgs.fetchFromGitHub {
          owner = "dvigo";
          repo = "modern-dark-pro-capsule-ohmyzsh";
          rev = "main";
          sha256 = "sha256-jRK3tMh0Y+eADjImQymkrosprNJOaCx6k9DUwIGYwDY=";
        };
      }
    ];
    sessionVariables = {
       MODERN_DARK_PRO_SHOW_CLOCK = "false";
       MODERN_DARK_PRO_PILL_STYLE = "round";
    };
    oh-my-zsh = {
      enable = true;
    };

    # Add extra config for vterm as suggested here
    # https://github.com/akermu/emacs-libvterm#shell-side-configuration
    initContent = lib.mkOrder 1000 ''
    vterm_printf() {
        if [ -n "$TMUX" ] \
            && { [ "''\${TERM%%-*}" = "tmux" ] \
                || [ "''\${TERM%%-*}" = "screen" ]; }; then
            # Tell tmux to pass the escape sequences through
            printf "\ePtmux;\e\e]%s\007\e\\" "$1"
        elif [ "''\${TERM%%-*}" = "screen" ]; then
            # GNU screen (screen, screen-256color, screen-256color-bce)
            printf "\eP\e]%s\007\e\\" "$1"
        else
            printf "\e]%s\e\\" "$1"
        fi
    }
    '';
  };
}
