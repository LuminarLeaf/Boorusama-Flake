{
  description = "Boorusama Linux build";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  nixConfig = {
    extra-substituters = ["https://boorusama.cachix.org"];
    extra-trusted-public-keys = ["boorusama.cachix.org-1:oGQkTvaFMP+Q4ekSsJh0fJqoVeEEo97PfrjYfGN6FJs="];
  };

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config = {allowUnfree = true;};
    };
  in {
    packages.${system} = {
      default = self.packages.${system}.boorusama;
      boorusama = pkgs.callPackage (
        {
          flutter335,
          fetchFromGitHub,
          autoPatchelfHook,
          alsa-lib,
          libepoxy,
          ffmpeg-headless,
          mdk-sdk,
          mpv-unwrapped,
          wrapGAppsHook3,
          lib,
          ...
        }:
          flutter335.buildFlutterApplication {
            pname = "boorusama";
            version = "4.3.4";

            src = fetchFromGitHub {
              owner = "khoadng";
              repo = "Boorusama";
              rev = "v4.3.4";
              sha256 = "sha256-3P99iMBLarkqI6uueo9fbcm1Zh3XZag6eX8vrGuoEtg=";
            };

            nativeBuildInputs = [
              autoPatchelfHook
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
              ++ pkgs.mpv-unwrapped.buildInputs;

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
          }
      ) {};
    };
  };
}
