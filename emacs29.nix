{ pkgs, config, ... }:

let 
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; }; 
in {

  services.emacs = {
   package = pkgs.emacs29;
   enable = true;
  };
}
