{
  lib,
  fetchFromGitHub,
  callPackage,
  flutter341,
  autoPatchelfHook,
  makeWrapper,
  wrapGAppsHook3,
  alsa-lib,
  libepoxy,
  ffmpeg-headless,
  mdk-sdk,
  mpv-unwrapped,
  ...
}:
flutter341.buildFlutterApplication (finalAttrs: {
  pname = "boorusama";
  version = "4.4.0";

  src = fetchFromGitHub {
    owner = "khoadng";
    repo = "Boorusama";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-wEdyEn7Gj3Y1xLkDPAgAuhcfbhjm1q1V/r0l1leYRAQ=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    wrapGAppsHook3
  ];

  buildInputs =
    [
      alsa-lib
      libepoxy
      ffmpeg-headless
      mdk-sdk
      mpv-unwrapped
    ]
    ++ mpv-unwrapped.buildInputs;

  customSourceBuilders = {
    flutter_avif_linux = callPackage ./flutter_avif_linux {};
  };

  pubspecLock = lib.importJSON ./pubspec.lock.json;

  flutterBuildFlags = [
    "--dart-define=IS_FOSS_BUILD=true"
    "--dart-define-from-file env/prod.json"
    "-t lib/main_foss.dart"
  ];

  preBuild = ''
    SLANG_PATH="$(packagePath slang)/bin/slang.dart"
    DART_RUN="dart run --packages=$(pwd)/.dart_tool/package_config.json"
    (cd packages/i18n && $DART_RUN $SLANG_PATH)
    (cd packages/i18n && $DART_RUN tools/generate_language.dart)
    (cd packages/booru_clients && $DART_RUN tools/generate_config.dart)
    (cd packages/booru_clients && $DART_RUN tools/generate_yaml_configs.dart)
    (cd packages/booru_clients && $DART_RUN tools/generate_registry.dart)
  '';

  postFixup = ''
    wrapProgram "$out/bin/boorusama" \
      --prefix LD_LIBRARY_PATH : "$out/app/boorusama/lib"
  '';

  gitHashes = {
    context_menus = "sha256-jW6sqtp6ofZW1ylqRPwrVqt6MiuzVrXYJ3U5gYXYhQk=";
    extended_image_library = "sha256-PEnZzJL08BtrcRqEA+9KmbDhIZou2D8YkBn1u4LCNZc=";
    flutter_launcher_icons = "sha256-oHQrBjxc9tFshlyGcXU8FdYD8pKFW6O/GDc9r9VZLNU=";
    flutter_avif = "sha256-L6+xYoTgii5BSSUIZqEYV4q9KMp2W4KdaCQmKu2pt8E=";
    fvp = "sha256-79O9INAnEAYsaxsDlLtnMfJqEV650a74UuNZ8Lu9FW4=";
    graphql_flutter = "sha256-GBqnOwVhcAUE86m4Vdd7sSJ/OwaDAWTemxK97ksy/3U=";
    reorderables = "sha256-01IIyshxRaACOWfa3qaqw6l/l1oUFCbgqU6p5QlloZI=";
    searchfield = "sha256-HXs1/q3zQSjGZYUKekfIR+/UCXhQOj56BtCqD1s6d9o=";
    selection_mode = "sha256-wrwP4hTYXtduu6DjSyFxgYpH5vOK9M13myQpePkZnYo=";
    webview_cookie_manager = "sha256-a64BxLcSV2D0ErCU/6XPl9Nnm9R8KkLouX6ol2nmtTo=";
  };

  meta = {
    description = " A client for booru sites built with Flutter ";
    mainProgram = "boorusama";
    homepage = "https://github.com/khoadng/Boorusama";
    license = lib.licenses.gpl3;
    platforms = [
      "x86_64-linux"
    ];
  };
})
