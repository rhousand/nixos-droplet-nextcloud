{
  pkgs,
  config,
  ...
}: let
  unstable = import <nixos-unstable> {config = {allowUnfree = true;};};
in {
  services.syncthing = {
    enable = true;
    user = "rhousand";
    dataDir = "/home/rhousand/Syncthing";
    configDir = "/home/rhousand/Syncthing/.config/syncthing";
    overrideDevices = true; # overrides any devices added or deleted through the WebUI
    overrideFolders = true; # overrides any folders added or deleted through the WebUI
    settings.devices = {
      "TD-C02FG1PYMD6N" = {id = "5JJ365Y-DX6NCRE-AM6H646-OFUAI4R-XIS6MYK-2J6TST5-RVDLFMV-EJZWPAB";};
    };
  };
}
