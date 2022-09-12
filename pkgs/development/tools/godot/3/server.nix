{ godot-debug-server }:

godot-debug-server.overrideAttrs (self: base: {
  pname = "godot-server";
  buildDescription = "server";
  buildTarget = "release";
})
