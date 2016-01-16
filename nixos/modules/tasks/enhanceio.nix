{ lib, config, ... }:

let kernel = config.boot.kernelPackages;
in

{
  ###### interface

  options = {
    services.enhanceio.enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = ''
        enable EnhanceIO
      '';
    };
  };


  ###### implementation

  config = lib.mkIf config.services.enhanceio.enable {
    boot.kernelModules = [ "enhanceio" ];
    boot.extraModulePackages = [ kernel.enhanceio ];
    services.udev.packages = [ kernel.enhanceio ];
  };
}
