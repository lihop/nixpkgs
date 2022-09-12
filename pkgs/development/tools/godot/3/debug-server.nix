{ godot-headless }:

godot-headless.overrideAttrs (self: base: {
  pname = "godot-debug-server";
  buildDescription = "debug server";
  shouldBuildTools = false;
})
