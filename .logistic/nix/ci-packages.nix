{ srcs ? import ./sources.nix { }
, pkgs ? import srcs.nixpkgs { }
}:
# These packages are needed both by developers and CI, hence they are extracted from the main `shell.nix`.
# Note that we could not "just" install those from Ubuntu's `apt` in the Docker images because these packages either don't exist (e.g. `ktfmt`) or are very old (e.g. `gradle` is in version 4.4 today in apt while the latest version is 8.10).
# As a side bonus, it makes dev machines consistent with CI.
[
  pkgs.ktfmt
  pkgs.gradle
  pkgs.kotlin
  pkgs.openjdk
]
