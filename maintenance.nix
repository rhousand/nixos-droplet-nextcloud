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
}
