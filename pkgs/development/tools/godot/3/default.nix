{ stdenv, lib
, alsa-lib
, alsa-plugins
, fetchFromGitHub
, freetype
, installShellFiles
, libGLU
, libpulseaudio
, libX11
, libXcursor
, libXext
, libXfixes
, libXi
, libXinerama
, libXrandr
, libXrender
, makeWrapper
, openssl
, pkg-config
, scons
, udev
, yasm
, zlib
}:

stdenv.mkDerivation (self: {
  pname = "godot";
  version = "3.5.1";

  src = fetchFromGitHub {
    owner = "godotengine";
    repo = "godot";
    rev = "${self.version}-stable";
    sha256 = "sha256-uHwTthyhfeQN0R1XjqZ+kGRa5WcpeQzA/DO9hZk4lvU=";
  };

  nativeBuildInputs = [
    installShellFiles
    pkg-config
    makeWrapper
    scons
  ];

  buildInputs = [
    alsa-lib
    freetype
    libGLU
    libpulseaudio
    libX11
    libXcursor
    libXext
    libXfixes
    libXi
    libXinerama
    libXrandr
    libXrender
    openssl
    udev
    yasm
    zlib
  ];

  patches = [
    ./detect.py.patch
    ./dont_clobber_environment.patch
  ];

  enableParallelBuilding = true;

  buildDescription = "X11 tools";
  buildPlatform = "x11";
  shouldBuildTools = true;
  buildTarget = "release_debug";

  shouldUseLinkTimeOptimization = self.buildTarget == "release";

  sconsFlags = [
    "platform=${self.buildPlatform}"
    "tools=${lib.boolToString self.shouldBuildTools}"
    "target=${self.buildTarget}"
    "bits=${toString stdenv.hostPlatform.parsed.cpu.bits}"
    "use_lto=${lib.boolToString self.shouldUseLinkTimeOptimization}"
  ];

  shouldWrapBinary = self.shouldBuildTools;
  shouldInstallHeaders = self.shouldBuildTools;
  shouldInstallShortcut = self.shouldBuildTools && self.buildPlatform != "server";

  outputs = ["out" "man"] ++ lib.optional self.shouldBuildTools "dev";

  builtGodotBinNamePattern = if self.buildPlatform == "server" then "godot_server.*" else "godot.*";

  godotBinInstallPath = "bin";
  installedGodotBinName = self.pname;

  installPhase = ''
    runHook preInstall

    echo "Installing godot binaries."
    outbin="$out/$godotBinInstallPath"
    mkdir -p "$outbin"
    cp -R bin/. "$outbin"
    mv "$outbin"/$builtGodotBinNamePattern "$outbin/$installedGodotBinName"

    if [ $shouldWrapBinary ]; then
      wrapProgram "$outbin/$installedGodotBinName" \
        --set ALSA_PLUGIN_DIR ${alsa-plugins}/lib/alsa-lib
    fi

    echo "Installing godot manual."
    installManPage misc/dist/linux/godot.6

    if [ $shouldInstallHeaders ]; then
      echo "Installing godot headers."
      mkdir -p "$dev"
      cp -R modules/gdnative/include "$dev"
    fi

    if [ $shouldInstallShortcut ]; then
      echo "Installing godot shortcut."
      mkdir -p "$out"/share/{applications,icons/hicolor/scalable/apps}
      cp misc/dist/linux/org.godotengine.Godot.desktop "$out"/share/applications
      cp icon.svg "$out"/share/icons/hicolor/scalable/apps/godot.svg
      cp icon.png "$out"/share/icons/godot.png
      substituteInPlace "$out"/share/applications/org.godotengine.Godot.desktop --replace "Exec=godot" "Exec=\"$outbin/$installedGodotBinName\""
    fi

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://godotengine.org";
    description = "Free and Open Source 2D and 3D game engine (" + self.buildDescription + ")";
    license = licenses.mit;
    platforms = [ "i686-linux" "x86_64-linux" "aarch64-linux" ];
    maintainers = with maintainers; [ twey rotaerk ];
  };
})
