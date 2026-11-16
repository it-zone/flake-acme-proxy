{
  description = "acme-proxy - ACME (RFC 8555) server in Rust";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          acme-proxy = pkgs.callPackage ./package.nix { };
        in
        {
          inherit acme-proxy;
          default = acme-proxy;
        });

      overlays.default = final: prev: {
        acme-proxy = final.callPackage ./package.nix { };
      };

      nixosModules = {
        acme-proxy = { ... }: {
          imports = [ ./nixos-module.nix ];
          nixpkgs.overlays = [ self.overlays.default ];
        };
        default = self.nixosModules.acme-proxy;
      };
    };
}
