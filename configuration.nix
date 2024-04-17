{ pkgs, ... }: {
  imports = [
    <home-manager/nixos>
    <agenix/modules/age.nix>
    ./emacs29.nix
    ./headscale.nix
    ./hardware-configuration.nix
    ./networking.nix # generated at runtime by nixos-infect
    ./host.nix
    ./syncthing.nix
    ./security.nix
  ];

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;

  virtualisation.docker.enable = true;

  networking.hostName = "nixos-droplet";
  networking.domain = "";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];


  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "no";

  programs.zsh.enable = true;
  environment.shells = with pkgs; [ zsh ];
  
  # System packages
   environment.systemPackages = with pkgs; [
	git
  ];
  users.groups = {
    sudoers = { };
  };
  users.users.root.openssh.authorizedKeys.keys = [
    ''ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDsVgHgdK6MoBZCSknLdJpQjp7prQWxs5VudYRPtyzHlJRC8jgLhl9+uTvGZmLRqJXg/OEiaF0hA3cYs81jcSR4uApxZmSGhqV+CrP7yCO8uAMKJHyOD3FF6OoY+8rEHpV/jmnN5W9UL2G5ult8ezocsTyUZ8rTYINUyC/0d/Nijo7fKumCg4fIu7aftCBrMQpe2BvYDc2mAmEXyhWTouOhQviLmkHFZVamZ8guyRRc3G0I/+q7UxyzHupNKjyD+Qt+3PwFQL3jeUqCLsS5fi5JNtaU6e/yUdKh8ekyz/3MAHmYSvjnCsB8cn3wnlsUhldoqbOkk1zwWKTtEnPzEGRaU5ShZ6ZnT5e5lBSEEXfsSHdLpogyuu7V6xoURwQi7LIC9Wbwai7Cuj0E6arlkAFdrKl8SBnnjqu8WVg7CW5pTx2bHHWd1WEZMDW/ZhRLEaxrZ5C8koSQE1Y+9ET7DKOuXKl5Eg591kg5jgtTJa6rkLSiHsR0tuToGzFhHrzn+RU= rhousand@TD-C02FG1GYMD6Ns-MacBook-Pro.local'' 
  ];
  users.users.rhousand = {
    shell = pkgs.zsh;
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
      "sudoers"
    ];
    openssh.authorizedKeys.keys = [
      ''ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDsVgHgdK6MoBZCSknLdJpQjp7prQWxs5VudYRPtyzHlJRC8jgLhl9+uTvGZmLRqJXg/OEiaF0hA3cYs81jcSR4uApxZmSGhqV+CrP7yCO8uAMKJHyOD3FF6OoY+8rEHpV/jmnN5W9UL2G5ult8ezocsTyUZ8rTYINUyC/0d/Nijo7fKumCg4fIu7aftCBrMQpe2BvYDc2mAmEXyhWTouOhQviLmkHFZVamZ8guyRRc3G0I/+q7UxyzHupNKjyD+Qt+3PwFQL3jeUqCLsS5fi5JNtaU6e/yUdKh8ekyz/3MAHmYSvjnCsB8cn3wnlsUhldoqbOkk1zwWKTtEnPzEGRaU5ShZ6ZnT5e5lBSEEXfsSHdLpogyuu7V6xoURwQi7LIC9Wbwai7Cuj0E6arlkAFdrKl8SBnnjqu8WVg7CW5pTx2bHHWd1WEZMDW/ZhRLEaxrZ5C8koSQE1Y+9ET7DKOuXKl5Eg591kg5jgtTJa6rkLSiHsR0tuToGzFhHrzn+RU= rhousand@TD-C02FG1GYMD6Ns-MacBook-Pro.local'' 
    ];
  };
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.rhousand = import ./home.nix;
  };
}
