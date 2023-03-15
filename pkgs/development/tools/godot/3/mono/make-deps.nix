{ godot-mono, nuget-to-nix }:

godot-mono.overrideAttrs (self: base: {
  pname = "godot-mono-make-deps";

  nativeBuildInputs = base.nativeBuildInputs ++ [ nuget-to-nix ];

  shouldConfigureNuget = false;

  outputs = [ "out" ];
  buildPhase = " ";
  installPhase = ''echo "No output intended. Run make-deps.sh instead." > $out'';

  makeDeps = ''
    set -e
    outdir="$(pwd)"
    wrkdir="$(mktemp -d)"
    trap 'rm -rf -- "$wrkdir"' EXIT
    pushd "$wrkdir" > /dev/null
      unpackPhase
      cd source
      patchPhase
      configurePhase

      # Without RestorePackagesPath set, it restores packages to a temp directory. Specifying
      # a path ensures we have a place to run nuget-to-nix.
      nugetRestore() { dotnet msbuild -t:Restore -p:RestorePackagesPath=nugetPackages $1; }

      nugetRestore modules/mono/glue/GodotSharp/GodotSharp.sln
      nugetRestore modules/mono/editor/GodotTools/GodotTools.sln

      nuget-to-nix nugetPackages > "$outdir"/deps.nix
    popd > /dev/null
  '';

  meta = base.meta // {
    description = "Derivation with no output that exists to provide an environment for make-deps.sh";
  };
})
