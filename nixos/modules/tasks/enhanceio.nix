{ pkgs, lib, config, ... }:

with lib;

let 

  kernel = config.boot.kernelPackages; 

  enhanceioCaches = attrValues config.enhanceioCaches;

  cacheOptions = { name, config, ... }: {

    options = {

      cacheName = mkOption {
        example = "root";
        type = types.str;
        description = "Name of the cache.";
      };

      hdd = mkOption {
        example = "/dev/sda";
        type = types.str;
        description = "Name of the source device.";
      };

      ssd = mkOption {
        example = "/dev/sdb";
        type = types.str;
        description = "Name of the ssd device.";
      };

      mode = mkOption {
        default = "wt";
        type = types.enum [ "ro" "wt" "wb" ];
        description = "Specifies the caching mode.";
      };

      blockSize = mkOption { 
        default = 4096;
        type = types.enum [ 2048 4096 8192 ]; 
        description = "Specifies the block size of each single cache entry.";
      };

      policy = mkOption {
        default = "fifo";
        type = types.enum [ "lru" "fifo" "rand" ];
        description = "Cache block replacement policy.";
      };

    };

    config = {
      cacheName = mkDefault name;
    };
  };

  udevRules = (cache: pkgs.stdenv.mkDerivation {
    name = "enhanceio-${cache.cacheName}-udev-rules";

    src = pkgs.linuxPackages.enhanceio.src; 

    patchPhase = ''
      substitute \
        Documents/94-Enhanceio.template 94-enhanceio-${cache.cacheName}.rules \
        --replace "/sbin/eio_cli" "${pkgs.eio_cli}/bin/eio_cli" \
        --replace "<cache_name>" "${cache.cacheName}" \
        --replace "<source_match_expr>" "${cache.hdd}" \
        --replace "<cache_match_expr>" "${cache.ssd}" \
        --replace "<mode>" "${cache.mode}" \
        --replace "<policy>" "${cache.policy}" \
        --replace "<block_size>" "${toString cache.blockSize}"
    '';

    installPhase = ''
      mkdir -p $out/etc/udev/rules.d
      cp 94-enhanceio-${cache.cacheName}.rules $out/etc/udev/rules.d
    '';
  });

in

{
  ###### interface

  options = {
    enhanceioCaches = mkOption {
      default = {}; 
      example = {
        "example" = {
          hdd = "/dev/sda";
          ssd = "/dev/sdb";
          mode = "wb";
          blockSize = 4096; 
          policy = "rand";
        };
      };
      type = types.loaOf types.optionSet;
      options = [ cacheOptions ];
      description = ''
       The EnhanceIO caches to be exist. 
       TODO: Cool description.
      '';
    };
  };

  ###### implementation

  config = { 
    boot.extraModulePackages = [ kernel.enhanceio ];

    # Load all the modules for now. In the future we might check to
    # see what modules actually need to be loaded depending in the
    # config.
    boot.kernelModules =
      [ "enhanceio"
        "enhanceio_lru"
        "enhanceio_fifo"
        "enhanceio_rand"
      ];

    # Add udev rules for caches so that they persist.
    services.udev.packages = map udevRules enhanceioCaches;

    # Emit systemd services to create caches 
    systemd.services =
      let
        createCache = cache:
          let
            eio_cli' = pkgs.eio_cli.override (origArgs: {
              # We can despose of the udev rules because they are generated 
              # seperately via a derivation.
              ruleDir = "/dev/null";
            });
          in nameValuePair "enhanceio-${cache.cacheName}"
          { description = "EnhanceIO Cache ${cache.cacheName}";
            wantedBy = [ "multiuser.target" ]; 
            path = [ pkgs.utillinux ];
            script = '' 
                ${eio_cli'}/bin/eio_cli create -c ${cache.cacheName} \
                  -d ${cache.hdd} -s ${cache.ssd} -p ${cache.policy} \
                  -m ${cache.mode} -b ${toString cache.blockSize}
              '';
            serviceConfig.Type = "oneshot";
          };
      in listToAttrs (map createCache enhanceioCaches);

  };

}
