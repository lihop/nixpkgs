{ godot }:

godot.overrideAttrs (self: base: {
  pname = "godot-export-templates";
  buildDescription = "nix export templates";
  shouldBuildTools = false;
  buildTarget = "release";
  godotBinInstallPath = "share/godot/templates/${self.version}.stable";
  installedGodotBinName = "nix_${self.buildPlatform}_64_${self.buildTarget}";

  # https://docs.godotengine.org/en/stable/development/compiling/optimizing_for_size.html
  # Stripping reduces the template size from around 500MB to 40MB for Linux.
  # This also impacts the size of the exported games.
  # This is added explicitly here because mkDerivation does not automatically
  # strip binaries in the template directory.
  stripAllList = (base.stripAllList or []) ++ [ "share/godot/templates" ];

  meta = base.meta // {
    homepage = "https://docs.godotengine.org/en/stable/development/compiling/compiling_for_x11.html#building-export-templates";
  };
})
