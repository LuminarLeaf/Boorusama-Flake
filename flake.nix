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
      boorusama = pkgs.callPackage ./package.nix {};
    };
  };
}
