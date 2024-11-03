# modules/default.nix
{config, lib, pkgs, ...}:

with lib;

let
  cfg = config.services.multivac;
in {
  options.services.multivac = {
    enable = mkEnableOption "Your application service";

    port = mkOption {
      type = types.port;
      default = 4000;
      description = "Port number for your application to listen on";
    };

    user = mkOption {
      type = types.str;
      default = "multivac";
      description = "User account under which your application runs";
    };

    group = mkOption {
      type = types.str;
      default = "multivac";
      description = "Group under which your application runs";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/multivac";
      description = "Directory to store application data";
    };

    environmentFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Environment file containing secrets";
    };

    # Add any other configuration options your app needs
    extraConfig = mkOption {
      type = types.attrs;
      default = {};
      description = "Additional configuration options for your application";
    };
  };

  config = mkIf cfg.enable {
    # Create system user and group
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      home = cfg.dataDir;
      createHome = true;
    };

    users.groups.${cfg.group} = {};

    # Ensure data directory exists with correct permissions
    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' 0750 ${cfg.user} ${cfg.group} - -"
    ];

    # SystemD service configuration
    systemd.services.multivac = {
      description = "Multivac Service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "postgresql.service" ];
      # Add other service dependencies if needed

      serviceConfig = {
        Type = "exec";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.dataDir;
        ExecStart = "${pkgs.multivac}/bin/start";
        Restart = "always";
        RestartSec = "10s";
        StateDirectory = "multivac";
        EnvironmentFile = mkIf (cfg.environmentFile != null) [ cfg.environmentFile ];
        
        # Hardening options
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [ cfg.dataDir ];
      };

      environment = {
        PORT = toString cfg.port;
        # Add other environment variables your app needs
      } // cfg.extraConfig;
    };
  };
}