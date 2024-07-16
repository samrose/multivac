{
  description = "Your new nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.


    # TODO: Add any other flake you might need
    # hardware.url = "github:nixos/nixos-hardware";

    # Shameless plug: looking for a way to nixify your themes and make
    # everything match nicely? Try nix-colors!
    # nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    inherit (self) outputs;
    # Supported systems for your flake packages, shell, etc.
    systems = [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    # This is a function that generates an attribute by calling a function you
    # pass to it, with each system as an argument
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # Your custom packages and modifications, exported as overlays
    # overlays = import ./overlays {inherit inputs;};
    # # Reusable nixos modules you might want to export
    # # These are usually stuff you would upstream into nixpkgs
    # nixosModules = import ./modules/nixos;

    # # NixOS configuration entrypoint
    # # Available through 'nixos-rebuild --flake .#your-hostname'
    # nixosConfigurations = {
    #   # FIXME replace with your hostname
    #   example = nixpkgs.lib.nixosSystem {
    #     specialArgs = {inherit inputs outputs;};
    #     modules = [
    #       # > Our main nixos configuration file <
    #       ./nixos/configuration.nix
    #     ];
    #   };
    # };
    devShell = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      mkShell = nixpkgs.legacyPackages.${system}.mkShell;
      basePackages = with pkgs; [alejandra bat erlang_26 elixir_1_16 docker-compose entr gnumake overmind jq mix2nix graphviz python3 unixtools.netstat];
      #propagatedPackages = with pkgs; [ google-chrome ];
      hooks = ''
        source .env
        # This is a shell hook that will be run when you enter the shell
        # You can use it to set environment variables, for example
        # the following is an example for setting up a phoenix framework project
        # with postgresql
        mkdir -p .nix-mix .nix-hex
        export MIX_HOME=$PWD/.nix-mix
        export HEX_HOME=$PWD/.nix-mix
        # make hex from Nixpkgs available
        # `mix local.hex` will install hex into MIX_HOME and should take precedence
        export PATH=$MIX_HOME/bin:$HEX_HOME/bin:$PATH
        export LANG=C.UTF-8
        # keep your shell history in iex
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
