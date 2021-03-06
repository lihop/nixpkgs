{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.vnstat;
in {
  options.services.vnstat = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable update of network usage statistics via vnstatd.
      '';
    };
  };

  config = mkIf cfg.enable {
    users.users.vnstatd = {
      isSystemUser = true;
      description = "vnstat daemon user";
      home = "/var/lib/vnstat";
      createHome = true;
    };

    systemd.services.vnstat = {
      description = "vnStat network traffic monitor";
      path = [ pkgs.coreutils ];
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      unitConfig.documentation = "man:vnstatd(1) man:vnstat(1) man:vnstat.conf(5)";
      preStart = "chmod 755 /var/lib/vnstat";
      serviceConfig = {
        ExecStart = "${pkgs.vnstat}/bin/vnstatd -n";
        ExecReload = "${pkgs.procps}/bin/kill -HUP $MAINPID";
        ProtectHome = true;
        PrivateDevices = true;
        PrivateTmp = true;
        User = "vnstatd";
      };
    };
  };
}
