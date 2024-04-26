{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "dst";
      plugins = [ 
        "docker-compose" 
        "docker" 
        "git"
        "sudo"
        "fzf"
        "systemadmin"
        "vi-mode"
        "zoxide"
      ];
      extraConfig = ''
        DISABLE_FZF_AUTO_COMPLETION="false"
        DISABLE_FZF_KEY_BINDINGS="false"
        FZF_BASE=$(fzf-share)
        source "$(fzf-share)/completion.zsh"
        export FPATH=~/.task:$FPATH
        source "$(fzf-share)/key-bindings.zsh"
        PROMPT="$PROMPT\$(vi_mode_prompt_info)"
        RPROMPT="\$(tf_prompt_info)\$(vi_mode_prompt_info)$RPROMPT"
      '';
    };
    initExtra = ''
      bindkey '^f' autosuggest-accept
    '';
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
}
