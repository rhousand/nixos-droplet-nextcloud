{ lib, ... }: {
  # This file was populated at runtime with the networking
  # details gathered from the active system.
  networking = {
    nameservers = [ "8.8.8.8"
 ];
    defaultGateway = "165.22.32.1";
    defaultGateway6 = {
      address = "2604:a880:800:10::1";
      interface = "eth0";
    };
    dhcpcd.enable = false;
    usePredictableInterfaceNames = lib.mkForce false;
    interfaces = {
      eth0 = {
        ipv4.addresses = [
          { address="165.22.33.151"; prefixLength=20; }
{ address="10.17.0.5"; prefixLength=16; }
        ];
        ipv6.addresses = [
          { address="2604:a880:800:10::e91:e001"; prefixLength=64; }
{ address="fe80::5866:dbff:fe95:d51a"; prefixLength=64; }
        ];
        ipv4.routes = [ { address = "165.22.32.1"; prefixLength = 32; } ];
        ipv6.routes = [ { address = "2604:a880:800:10::1"; prefixLength = 128; } ];
      };
      
    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="5a:66:db:95:d5:1a", NAME="eth0"
    ATTR{address}=="26:fa:96:33:3a:1a", NAME="eth1"
  '';
}
