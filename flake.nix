# /etc/nixos/flake.nix
{
  description = "flake for nixos-droplet";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    crowdsec = {
      #url = "github:kampka/nix-flake-crowdsec";
      url = "git+file:///home/rhousand/repos/nix-flake-crowdsec";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = { 
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = flakes @ { 
    self, 
    nixpkgs, 
    crowdsec,
    home-manager,
    ...
   }: {
    nixosConfigurations = {
      nixos-droplet = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
           crowdsec.nixosModules.crowdsec
           ({ pkgs, lib, ... }: {
             services.crowdsec = {
               enable = true;
               enrollKeyFile = "/home/rhousand/crowdsec.key";
               settings = {
                 api.server = {
                   listen_uri = "127.0.0.1:8080";
                 };
               };
             };
           })
           crowdsec.nixosModules.crowdsec-firewall-bouncer
           ({ pkgs, lib, ... }: {
	     nixpkgs.overlays = [crowdsec.overlays.default];
             services.crowdsec-firewall-bouncer = {
               enable = true;
               settings = {
                 api_key = "kajbpijbjalkepciaske3094";
                 api_url = "http://localhost:8080";
               };
             };
           })
          ./configuration.nix
        ];
      };
    };
  };
}

