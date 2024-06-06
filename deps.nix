{ lib, beamPackages, overrides ? (x: y: {}) }:

let
  buildRebar3 = lib.makeOverridable beamPackages.buildRebar3;
  buildMix = lib.makeOverridable beamPackages.buildMix;
  buildErlangMk = lib.makeOverridable beamPackages.buildErlangMk;

  self = packages // (overrides self packages);

  packages = with beamPackages; with self; {
    db_connection = buildMix rec {
      name = "db_connection";
      version = "2.6.0";

      src = fetchHex {
        pkg = "db_connection";
        version = "${version}";
        sha256 = "c2f992d15725e721ec7fbc1189d4ecdb8afef76648c746a8e1cad35e3b8a35f3";
      };

      beamDeps = [ telemetry ];
    };

    decimal = buildMix rec {
      name = "decimal";
      version = "2.1.1";

      src = fetchHex {
        pkg = "decimal";
        version = "${version}";
        sha256 = "53cfe5f497ed0e7771ae1a475575603d77425099ba5faef9394932b35020ffcc";
      };

      beamDeps = [];
    };

    jason = buildMix rec {
      name = "jason";
      version = "1.4.1";

      src = fetchHex {
        pkg = "jason";
        version = "${version}";
        sha256 = "fbb01ecdfd565b56261302f7e1fcc27c4fb8f32d56eab74db621fc154604a7a1";
      };

      beamDeps = [ decimal ];
    };

    libcluster = buildMix rec {
      name = "libcluster";
      version = "3.3.3";

      src = fetchHex {
        pkg = "libcluster";
        version = "${version}";
        sha256 = "7c0a2275a0bb83c07acd17dab3c3bfb4897b145106750eeccc62d302e3bdfee5";
      };

      beamDeps = [ jason ];
    };

    libcluster_postgres = buildMix rec {
      name = "libcluster_postgres";
      version = "0.1.2";

      src = fetchHex {
        pkg = "libcluster_postgres";
        version = "${version}";
        sha256 = "b957ca609ec5dcddc37342a756bfc027029225bfb089bf0b32974f0ec0cac237";
      };

      beamDeps = [ libcluster postgrex ];
    };

    postgrex = buildMix rec {
      name = "postgrex";
      version = "0.17.3";

      src = fetchHex {
        pkg = "postgrex";
        version = "${version}";
        sha256 = "946cf46935a4fdca7a81448be76ba3503cff082df42c6ec1ff16a4bdfbfb098d";
      };

      beamDeps = [ db_connection decimal jason ];
    };

    telemetry = buildRebar3 rec {
      name = "telemetry";
      version = "1.2.1";

      src = fetchHex {
        pkg = "telemetry";
        version = "${version}";
        sha256 = "dad9ce9d8effc621708f99eac538ef1cbe05d6a874dd741de2e689c47feafed5";
      };

      beamDeps = [];
    };
  };
in self

