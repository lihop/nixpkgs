{ godot-mono-headless }:

godot-mono-headless.overrideAttrs (self: base: {
  pname = "godot-mono-debug-server";
  buildDescription = "mono debug server";
  shouldBuildTools = false;
})
