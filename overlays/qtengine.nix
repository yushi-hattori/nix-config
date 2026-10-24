# qtengine — Qt platform theme engine with Qt5 + Qt6 support.
#
# nixpkgs' `qtengine` is Qt6-only (`-DBUILD_QT5=OFF`), but VLC is a Qt5 app, so
# its client-side title bar and dialogs would never pick up the theme. This
# rebuilds the upstream qtengine (kossLAN/qtengine) with both Qt5 and Qt6
# support, following the author's own nix/default.nix. The Qt6 plugin lands in
# `out`, the Qt5 plugin in the `qt5` output.
#
# Qt5/Qt6 deps can't share `buildInputs`, so the Qt5 and KF5 locations are
# pinned via `-D*_DIR` cmake flags instead (the upstream nixpkgs pattern).
#
# To bump: update `version` + `hash` from the upstream release.
final: prev: {
  qtengine = final.stdenv.mkDerivation (finalAttrs: {
    pname = "qtengine";
    version = "0.2.2";

    src = final.fetchFromGitHub {
      owner = "kossLAN";
      repo = "qtengine";
      tag = finalAttrs.version;
      hash = "sha256-9nhKFJ9AUxIS7wZ3be7Vxy36Q+4lgihB/RLooJ41niE=";
    };

    outputs = [ "out" "qt5" ];

    nativeBuildInputs = [
      final.cmake
      final.ninja
    ];

    buildInputs = [
      final.qt6Packages.qtbase
      final.kdePackages.kconfig
      final.kdePackages.kcolorscheme
      final.kdePackages.kiconthemes
    ];

    cmakeFlags = [
      "-DQT6_PLUGINDIR=${builtins.placeholder "out"}/${final.qt6Packages.qtbase.qtPluginPrefix}"
      "-DQT5_PLUGINDIR=${builtins.placeholder "qt5"}/${final.libsForQt5.qtbase.qtPluginPrefix}"
      "-DQT5_LIBDIR=${builtins.placeholder "qt5"}/lib"
      "-DQt5_DIR=${final.libsForQt5.qtbase.dev}/lib/cmake/Qt5"
      "-DQt5Core_DIR=${final.libsForQt5.qtbase.dev}/lib/cmake/Qt5Core"
      "-DQt5DBus_DIR=${final.libsForQt5.qtbase.dev}/lib/cmake/Qt5DBus"
      "-DQt5Gui_DIR=${final.libsForQt5.qtbase.dev}/lib/cmake/Qt5Gui"
      "-DQt5Widgets_DIR=${final.libsForQt5.qtbase.dev}/lib/cmake/Qt5Widgets"
      "-DQt5Xml_DIR=${final.libsForQt5.qtbase.dev}/lib/cmake/Qt5Xml"
      "-DQt5ThemeSupport_DIR=${final.libsForQt5.qtbase.dev}/lib/cmake/Qt5ThemeSupport"
      "-DQt5ThemeSupport_LIBRARY=${final.libsForQt5.qtbase.out}/lib/libQt5ThemeSupport.a"
      "-DQt5ThemeSupport_INCLUDE_DIR=${final.libsForQt5.qtbase.dev}/include/QtThemeSupport/${final.libsForQt5.qtbase.version}"
      "-DQt5Network_DIR=${final.libsForQt5.qtbase.dev}/lib/cmake/Qt5Network"
      "-DQt5Qml_DIR=${final.libsForQt5.qtdeclarative.dev}/lib/cmake/Qt5Qml"
      "-DQt5Quick_DIR=${final.libsForQt5.qtdeclarative.dev}/lib/cmake/Qt5Quick"
      "-DQt5QmlModels_DIR=${final.libsForQt5.qtdeclarative.dev}/lib/cmake/Qt5QmlModels"
      "-DQt5QuickControls2_DIR=${final.libsForQt5.qtquickcontrols2.dev}/lib/cmake/Qt5QuickControls2"
      "-DKF5Auth_DIR=${final.libsForQt5.__internalKF5.kauth.dev}/lib/cmake/KF5Auth"
      "-DKF5Codecs_DIR=${final.libsForQt5.__internalKF5.kcodecs.dev}/lib/cmake/KF5Codecs"
      "-DKF5Config_DIR=${final.libsForQt5.__internalKF5.kconfig.dev}/lib/cmake/KF5Config"
      "-DKF5ConfigWidgets_DIR=${final.libsForQt5.__internalKF5.kconfigwidgets.dev}/lib/cmake/KF5ConfigWidgets"
      "-DKF5CoreAddons_DIR=${final.libsForQt5.__internalKF5.kcoreaddons.dev}/lib/cmake/KF5CoreAddons"
      "-DKF5GuiAddons_DIR=${final.libsForQt5.__internalKF5.kguiaddons.dev}/lib/cmake/KF5GuiAddons"
      "-DKF5IconThemes_DIR=${final.libsForQt5.__internalKF5.kiconthemes.dev}/lib/cmake/KF5IconThemes"
      "-DKF5WidgetsAddons_DIR=${final.libsForQt5.__internalKF5.kwidgetsaddons.dev}/lib/cmake/KF5WidgetsAddons"
    ];

    dontWrapQtApps = true;

    meta = {
      description = "Minimal Qt platform theme";
      homepage = "https://github.com/kossLAN/qtengine";
      license = final.lib.licenses.bsd2;
      platforms = final.lib.platforms.linux;
    };
  });
}
