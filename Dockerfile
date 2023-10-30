FROM nixos/nix
WORKDIR sd-image
COPY flake.nix .
COPY flake.lock .
ENTRYPOINT nix --extra-experimental-features nix-command --extra-experimental-features flakes build '.#nixosConfigurations.kube-node-2.config.system.build.sdImage' && echo "docker cp $HOSTNAME:$(find $(readlink result) -type f -name "nixos-sd-image*") ."
