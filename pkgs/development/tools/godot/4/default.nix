{ stdenv
, lib
, fetchFromGitHub
, installShellFiles
, autoPatchelfHook
, pkg-config
, scons
, vulkan-loader
, libX11
, libXcursor
, libXinerama
, libXi
, libXrandr
, libXext
, libXfixes
, libGL
, freetype
, alsa-lib
, libpulseaudio
, dbus
, speechd
, fontconfig
, udev
, withPulseaudio ? false
, withDbus ? true
, withSpeechd ? false
, withFontconfig ? true
, withUdev ? true
, withTouch ? true
}:

let
  # Options from godot/platform/linuxbsd/detect.py
  options = {
    pulseaudio = withPulseaudio;
    dbus = withDbus; # Use D-Bus to handle screensaver and portal desktop settings
    speechd = withSpeechd; # Use Speech Dispatcher for Text-to-Speech support
    fontconfig = withFontconfig; # Use fontconfig for system fonts support
    udev = withUdev; # Use udev for gamepad connection callbacks
    touch = withTouch; # Enable touch events
  };
in
stdenv.mkDerivation rec {
  pname = "godot";
  version = "4.0-beta12";

  src = fetchFromGitHub {
    owner = "godotengine";
    repo = "godot";
    rev = "3c9bf4bc210a8e6a208f30ca59de4d4d7e18c04d";
    sha256 = "sha256-8eNEnMyCP2ohx7sVmdFDCANZSWkvy/1xy1kIE770CrQ=";
  };

  nativeBuildInputs = [
    pkg-config
    autoPatchelfHook
    installShellFiles
  ];

  buildInputs = [
    scons
  ]
  ++ runtimeDependencies
  # Necessary to make godot see fontconfig.lib and dbus.lib
  ++ lib.optional withFontconfig fontconfig
  ++ lib.optional withDbus dbus;

  runtimeDependencies = [
    vulkan-loader
    alsa-lib
    libGL
    libX11
    libXcursor
    libXext
    libXfixes
    libXi
    libXinerama
    libXrandr
  ]
  ++ lib.optional withPulseaudio libpulseaudio
  ++ lib.optional withDbus dbus.lib
  ++ lib.optional withSpeechd speechd
  ++ lib.optional withFontconfig fontconfig.lib
  ++ lib.optional withUdev udev;

  patches = [
    # Godot expects to find xfixes inside xi, but nix's pkg-config only
    # gives the libs for the requested package (ignoring the propagated-build-inputs)
    ./xfixes.patch
  ];

  enableParallelBuilding = true;

  sconsFlags = "platform=linuxbsd target=editor production=true CXXFLAGS=-Wno-odr";
  preConfigure = ''
    sconsFlags+=" ${
      lib.concatStringsSep " "
      (lib.mapAttrsToList (k: v: "${k}=${builtins.toJSON v}") options)
    }"
  '';

  outputs = [ "out" "man" ];

  installPhase = ''
    mkdir -p "$out/bin"
    cp bin/godot.* $out/bin/godot

    installManPage misc/dist/linux/godot.6

    mkdir -p "$out"/share/{applications,icons/hicolor/scalable/apps}
    cp misc/dist/linux/org.godotengine.Godot.desktop "$out/share/applications/"
    substituteInPlace "$out/share/applications/org.godotengine.Godot.desktop" \
      --replace "Exec=godot" "Exec=$out/bin/godot"
    cp icon.svg "$out/share/icons/hicolor/scalable/apps/godot.svg"
    cp icon.png "$out/share/icons/godot.png"
  '';

  meta = with lib; {
    homepage = "https://godotengine.org";
    description = "Free and Open Source 2D and 3D game engine";
    license = licenses.mit;
    platforms = [ "i686-linux" "x86_64-linux" ];
    maintainers = with maintainers; [ twey shiryel ];
  };
}
