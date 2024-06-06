{
  lib,
  beamPackages,
  ...
}: 
beamPackages.mixRelease rec {
    pname = "multivac";
    version = "0.0.1";
    # "self" defaults to the root of your project.
    # amend the path if it is non-standard with `self + "/src";`, for example
    src = ../.;

    MIX_ENV = "prod";

    mixNixDeps = import ../deps.nix {
      inherit lib beamPackages;
    };
  

    # flox will create a "fixed output derivation" based on
    # the total package of fetched mix dependencies, identified by a hash
    # mixFodDeps = packages.fetchMixDeps {
    #   inherit version src;
    #   pname = "hello-elixir";
    #   # nix will complain when you build, since it can't verify the hash of the deps ahead of time.
    #   # In the error message, it will tell you the right value to replace this with
    #   #sha256 = lib.fakeSha256;
    #   sha256 = "sha256-3lhyPcgIIGB8jUnHL1Hx90KXymbi190RFJ297NMivfs=";
    #   # if you have build time environment variables, you should add them here
    #   #MY_VAR="value";
    #   buildInputs = [];

    #   propagatedBuildInputs = [];
    # };

    # for phoenix framework you can uncomment the lines below
    # for external task you need a workaround for the no deps check flag
    # https://github.com/phoenixframework/phoenix/issues/2690
    # You can also add any post-build steps here. It's just bash!
    #postBuild = ''
    # mix do deps.loadpaths --no-deps-check, phx.digest
    # mix phx.digest --no-deps-check
    # mix do deps.loadpaths --no-deps-check
    #'';
}
