{ godot-mono-debug-server }:

godot-mono-debug-server.overrideAttrs (self: base: {
  pname = "godot-mono-server";
  buildDescription = "mono server";
  buildTarget = "release";
})
