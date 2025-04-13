{
  description = "Advent of Nickel 2022";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    nickel.url = "github:tweag/nickel/1.7.0";
  };

  outputs = { self, nixpkgs, nickel }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
      };
    in
    {
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
      devShell.x86_64-linux = pkgs.mkShell {
        buildInputs = [ nickel.packages.x86_64-linux.default ];
      };
    };
}
