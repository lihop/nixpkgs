{
  lib,
  fetchFromGitLab,
  cmake,
  extra-cmake-modules,
  ffmpeg_6,
  openal,
  stdenv,
  libsForQt5,
}:

stdenv.mkDerivation rec {
  pname = "subtitlecomposer";
  version = "0.8.1";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "multimedia";
    repo = "subtitlecomposer";
    rev = "v${version}";
    hash = "sha256-5RBrxOy1EIgDLb21r1y+Pou8d/j05a1YYMRJh1n8vSA=";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    libsForQt5.wrapQtAppsHook
  ];
  buildInputs = [
    ffmpeg_6
    openal
  ]
  ++ (with libsForQt5; [
    kcodecs
    kconfig
    kconfigwidgets
    kcoreaddons
    ki18n
    kio
    ktextwidgets
    kwidgetsaddons
    kxmlgui
    sonnet
  ]);

  meta = with lib; {
    homepage = "https://apps.kde.org/subtitlecomposer";
    description = "Open source text-based subtitle editor";
    longDescription = ''
      An open source text-based subtitle editor that supports basic and
      advanced editing operations, aiming to become an improved version of
      Subtitle Workshop for every platform supported by Plasma Frameworks.
    '';
    changelog = "https://invent.kde.org/multimedia/subtitlecomposer/-/blob/master/ChangeLog";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ kugland ];
    mainProgram = "subtitlecomposer";
    platforms = with platforms; linux ++ freebsd ++ windows;
  };
}
