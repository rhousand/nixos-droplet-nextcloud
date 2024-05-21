{
  inputs = {
    crowdsec = {
      url = "github:kampka/nix-flake-crowdsec";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = flakes @ {
    self,
    nixpkgs,
    crowdsec,
    ...
  }: {
    nixosConfigurations.nixos-droplet = nixpkgs.lib.nixosSystem {
      # ...
      modules = [
        # ...
        crowdsec.nixosModules.crowdsec

        ({
          pkgs,
          lib,
          ...
        }: {
          services.crowdsec = {
            enable = true;
            enrollKeyFile = "../../crowdsec.key";
            settings = {
              api.server = {
                listen_uri = "127.0.0.1:8080";
              };
            };
          };
        })
      ];
    };
  };
}
