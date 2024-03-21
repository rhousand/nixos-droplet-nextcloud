{ pkgs, config, ... }:
{
  security.acme = {
    acceptTerms = true;
    defaults.email = "rhousand@gmail.com";
  };
  security.sudo.extraRules = [
    { 
      groups = [ "sudoers" ]; 
      commands = [ { command =  "ALL"; options = [ "NOPASSWD" ]; } ];
    }  
  ];
}
