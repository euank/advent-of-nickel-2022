{
  description = "Advent of Nickel 2022";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { self, nixpkgs }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
      };
    in
    {
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
      devShell.x86_64-linux = pkgs.mkShell {
        buildInputs = with pkgs; [ nickel ];
      };
    };
}
