{
  fetchFromGitHub,
  stdenv,
  replaceVars,
  meson,
  ninja,
  cmake,
  nasm,
  pkg-config,
  rustPlatform,
  rustc,
  cargo,
  glibc,
  ...
}: {
  version,
  src,
  ...
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "flutter_avif_linux";

  inherit version;
  inherit (src) passthru;

  src = fetchFromGitHub {
    owner = "yekeskin";
    repo = "flutter_avif";
    tag = "${finalAttrs.version}";
    hash = "sha256-skpJfC7P79TIRCyh8MkvSYFNX36JbV15AzNqjPdbH6Q=";
  };

  patches = [(replaceVars ./add-Cargo.lock.patch {dir = "/rust";})];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    patches = [(replaceVars ./add-Cargo.lock.patch {dir = "";})];
    hash = "sha256-Oa8ZncbuGKhJOY4VabFY55Si/0WD/clpYzPPIHEi+qg=";
  };

  dontConfigure = true;

  cargoRoot = "rust";

  buildInputs = [
    meson
    ninja
    cmake
    nasm
    pkg-config
    rustPlatform.cargoSetupHook
    rustc
    cargo
    glibc
  ];

  buildPhase = ''
    runHook preBuild

    cd rust
    cargo build --release

    mkdir -p $out/linux
    cp ./target/release/libflutter_avif.so $out/linux/libflutter_avif.so

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    cd $src
    cp -rn ./flutter_avif_linux/* $out

    runHook postInstall
  '';
})
