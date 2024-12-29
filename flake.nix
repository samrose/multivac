{
  description = "Your application flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    inherit (self) outputs;
    systems = [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    # Example usage in another flake:
    #
    # {
    #   inputs.multivac.url = "github:samrose/multivac";
    #   
    #   outputs = { self, nixpkgs, multivac }: {
    #     nixosConfigurations.mysystem = nixpkgs.lib.nixosSystem {
    #       modules = [
    #         multivac.nixosModules.default
    #         {
    #           services.multivac = {
    #             enable = true;
    #             port = 4000;
    #             environmentFile = "/path/to/env/file";
    #           };
    #         }
    #       ];
    #     };
    #   };
    # }

    # Expose the NixOS module
    nixosModules.default = import ./modules;
    
    # For backwards compatibility
    nixosModules.multivac = self.nixosModules.default;

    # Your custom packages
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});

    # Formatter for your nix files
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);

    devShell = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      mkShell = nixpkgs.legacyPackages.${system}.mkShell;
      basePackages = with pkgs; [
        alejandra
        bat
        erlang_27
        elixir_1_18
        docker-compose
        entr
        gnumake
        overmind
        jq
        mix2nix
        graphviz
        python3
        unixtools.netstat
        dbmate
      ];
      hooks = ''
        source .env
        mkdir -p .nix-mix .nix-hex
        export MIX_HOME=$PWD/.nix-mix
        export HEX_HOME=$PWD/.nix-mix
        export PATH=$MIX_HOME/bin:$HEX_HOME/bin:$PATH
        export ERL_AFLAGS="-kernel shell_history enabled"
      '';
    in
      mkShell {
        shellHook = hooks;
        buildInputs = basePackages;
        propagatedBuildInputs = basePackages;
      });
  };
}