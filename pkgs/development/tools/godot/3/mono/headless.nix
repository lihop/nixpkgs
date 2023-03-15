{ godot-mono }:

godot-mono.overrideAttrs (self: base: {
  pname = "godot-mono-headless";
  buildDescription = "mono headless";
  buildPlatform = "server";
})
