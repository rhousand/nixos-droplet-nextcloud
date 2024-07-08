{ config, pkgs, flakes, ... }:

{
  system.autoUpgrade = {
    enable = true;
    dates = "02:00";
    flake = flakes.self.outPath;
    flags = [
      "--update-input"
      "nixpkgs"
      "-L"
    ];
    randomizedDelaySec = "30min";
  };
  nix.gc = {
    automatic = true;
    dates = "00:01";
    options = "--delete-older-than 10d";
  };
  nix.optimise = {
    automatic = true;
    dates = [ "04:00" ];
  };
}
