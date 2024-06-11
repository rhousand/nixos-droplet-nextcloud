{
  config,
  pkgs,
  agenix,
  ...
}: {
  home.enableNixpkgsReleaseCheck = false;
  home = {
    username = "rhousand";
    homeDirectory = "/home/rhousand";
    ## using the below config does work but it makes the flake impure. A better solution is to set the path option when adding the secret
    #file.".rhtest".source = osConfig.age.secrets.secret2.path; 
    packages = with pkgs; [
      age
      bat # a better cat
      bottom
      neofetch
      ripgrep
      tealdeer
      zoxide # a better cd
    ];
    stateVersion = "23.11";
  };

  imports = [
    ./apps/zsh.nix
  ];
}
