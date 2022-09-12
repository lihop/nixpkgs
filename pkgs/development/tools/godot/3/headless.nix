{ godot }:

godot.overrideAttrs (self: base: {
  pname = "godot-headless";
  buildDescription = "headless";
  buildPlatform = "server";
})
