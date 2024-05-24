{
  pkgs,
  config,
  crowdsec,
  agenix,
  ...
}: let
  #unstable = import <nixos-unstable> {config = {allowUnfree = true;};};
  #agenix = import <agenix> {config = {allowUnfree = true;};};
in {
  environment.systemPackages = with pkgs; [
    docker
    vim
    nvd
    ripgrep
    screen
    tailscale
    tealdeer
    #inputs.agenix.packages."${system}".default
  ];

  age.secrets.secret1 = {
    file = ./secrets/secret1.age;
    mode = "770";
    owner = "nextcloud";
    group = "nextcloud";
  };

  age.secrets.secret2 = {
    file = ./secrets/secret2.age;
    path = "/home/rhousand/.rhtest";
    mode = "770";
    owner = "rhousand";
    group = "wheel";
  };
  # System Services
  services.tailscale.enable = true;

  #services.openssh.settings.LogLevel = "VERBOSE";

  services.fail2ban = {
    enable = false;
    ignoreIP = [
      "10.0.0.0/24"
    ];
    jails = {
      nginx-http-auth = ''
        enabled  = true
        port     = http,https
        logpath  = /var/log/nginx/*.log
        backend  = polling
        journalmatch =
      '';
      nginx-botsearch = ''
        enabled  = true
        port     = http,https
        logpath  = /var/log/nginx/*.log
        backend  = polling
        journalmatch =
      '';
      nginx-bad-request = ''
        enabled  = true
        port     = http,https
        logpath  = /var/log/nginx/*.log
        backend  = polling
        journalmatch =
      '';
    };
  };
  #services.fail2ban.enable = true;

  services.fail2ban.bantime-increment.multipliers = "1 2 4 6 8 16 32 64";

  services.postfix.enable = true;

  services.nextcloud = {
    enable = true;
    hostName = "next.gladstone-life.com";
    https = true;
    phpOptions."opcache.interned_strings_buffer" = "23";
    phpOptions."output_buffering" = "off";
    config.adminpassFile = config.age.secrets.secret1.path;
    #config.adminpassFile = "${pkgs.writeText "adminpass" "This is where the password would be"}";
    settings.default_phone_region = "US";
    package = pkgs.nextcloud29;
    configureRedis = true;
    autoUpdateApps.enable = true;
    extraApps = {
      inherit (config.services.nextcloud.package.packages.apps) cookbook contacts calendar tasks notes onlyoffice;
      ## Unsplash does not support nextcloud 28 at this time however it should be added above as extraApps when ready.
      #unsplash =  pkgs.fetchNextcloudApp rec {
      #  url = "https://github.com/nextcloud/unsplash/releases/download/v2.2.1/unsplash.tar.gz";
      #  sha256 = "/fOkTIRAwMgtgqAykWI+ahB1uo6FlvUaDNKztCyBQfk=";
      #  license = "free";
      #};
      #cookbook = pkgs.fetchNextcloudApp rec {
      #  url = "https://github.com/nextcloud/cookbook/releases/download/v0.10.2/Cookbook-0.10.2.tar.gz";
      #  sha256 = "sha256-XgBwUr26qW6wvqhrnhhhhcN4wkI+eXDHnNSm1HDbP6M=";
      #  license = "free";
      #};
    };
    extraAppsEnable = true;
    settings = {
      mail_smtpmode = "sendmail";
      mail_sendmailmode = "pipe";
    };
  };
  services.onlyoffice = {
    enable = true;
    hostname = "onlyoffice.gladstone-life.com";
  };

  services.nginx.virtualHosts = {
    ${config.services.nextcloud.hostName} = {
      forceSSL = true;
      enableACME = true;
      extraConfig = ''
        error_log syslog:server=unix:/dev/log;
        access_log syslog:server=unix:/dev/log combined;
      '';
    };

    "onlyoffice.gladstone-life.com" = {
      forceSSL = true;
      enableACME = true;
      ## Push access logs to journald
      extraConfig = ''
        error_log syslog:server=unix:/dev/log;
        access_log syslog:server=unix:/dev/log combined;
      '';
    };
  };

  # System Program configurations
  programs.bandwhich.enable = true;

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/rhousand/repos/nixos-droplet-nextcloud";
  };

  programs.neovim = {
    enable = true;
    vimAlias = false;
    viAlias = false;
    configure = {
      customRC = ''
        set number relativenumber
        set cc=120
        set list
        set listchars=tab:→\ ,space:·,nbsp:␣,trail:•,eol:¶,precedes:«,extends:»
        if &diff
          colorscheme blue
        endif
      '';
      packages.myVimPackage = with pkgs.vimPlugins; {
        start = [vim-nix];
      };
    };
  };

  environment.variables.EDITOR = "nvim";

  # Add Crowdsec Bouncer Service
  systemd.services.crowdsec.serviceConfig = {
    ExecStartPre = let
      script = pkgs.writeScriptBin "register-bouncer" ''
        #!${pkgs.runtimeShell}
        set -eu
        set -o pipefail

        if ! cscli bouncers list | grep -q "my-bouncer"; then
          cscli bouncers add "my-bouncer" --key "kajbpijbjalkepciaske3094"
        fi
      '';
    in ["${script}/bin/register-bouncer"];
  };
  # Allow Crowdsec Monitor SSHD via Systemd
  services.crowdsec = let
    ##yaml = (pkgs.formats.yaml {}).generate;
    ##acquisitions_file = yaml "acquisitions.yaml" {
    ##  source = "journalctl";
    ##  journalctl_filter = ["_SYSTEMD_UNIT=sshd.service" ];
    ##  labels.type = "syslog";
    ##  filenames = [ "/var/log/nginx/*.log"];
    ##  labels.type = "nginx";
    ##};
    acquisitions_file =
      pkgs.writeText "acquisitions.yaml"
      ''
        journalctl_filter:
         - _SYSTEMD_UNIT=sshd.service
        labels:
          type: syslog
        source: journalctl
        ---
        journalctl_filter:
         - _SYSTEMD_UNIT=nginx.service
        labels:
          type: nginx
        source: journalctl
        #filenames:
        #  - /var/log/nginx/*.log
        #labels:
        #  type: nginx
      '';
  in {
    enable = true;
    allowLocalJournalAccess = true;
    settings = {
      crowdsec_service.acquisition_path = acquisitions_file;
    };
  };

  # create a oneshot job to authenticate to Tailscale
  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";

    # make sure tailscale is running before trying to connect to tailscale
    after = ["network-pre.target" "tailscale.service"];
    wants = ["network-pre.target" "tailscale.service"];
    wantedBy = ["multi-user.target"];

    # set this service as a oneshot job
    serviceConfig.Type = "oneshot";

    # have the job run this shell script
    script = with pkgs; ''
      # wait for tailscaled to settle
      sleep 2

      # check if we are already authenticated to tailscale
      status="$(${tailscale}/bin/tailscale status --json | ${jq}/bin/jq -r .BackendState)"
      if [ $status = "Running" ]; then # if so, then do nothing
        exit 0
      fi

      # otherwise authenticate with tailscale with onetime key
      ${tailscale}/bin/tailscale up --authkey tskey-auth-k9g3HM3CNTRL-omkwgzKt2S2e6cRE6KChL2Dbum2RKMbdg

    '';
  };

  networking.firewall = {
    # enable the firewall
    enable = true;

    # always allow traffic from your Tailscale network
    trustedInterfaces = ["tailscale0"];

    # Open UDP ports on public internet
    allowedUDPPorts = [config.services.tailscale.port 5150 3478];

    # Open TCP ports on public internet
    allowedTCPPorts = [9991 22 5150 80 8443 3478 443];
  };

  # enable closed source packages such as the minecraft server
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "24.05";
}
