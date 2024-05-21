{
  config,
  pkgs,
  ...
}: {
  home.enableNixpkgsReleaseCheck = false;
  home = {
    username = "rhousand";
    homeDirectory = "/home/rhousand";
    file.".rhtest".source = /run/agenix/secret2;
    packages = with pkgs; [
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
