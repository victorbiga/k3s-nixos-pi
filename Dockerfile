FROM nixos/nix

WORKDIR /sd-image

# Copy necessary files for the build
COPY flake.nix .
COPY flake.lock .
COPY common.nix .

# Define a build argument
ARG NODE_NAME
ENV NODE_NAME=${NODE_NAME}

# Set the entrypoint to build the specified node's SD image
ENTRYPOINT nix --extra-experimental-features nix-command --extra-experimental-features flakes build ".#nixosConfigurations.${NODE_NAME}.config.system.build.sdImage" && \
  echo "docker cp $HOSTNAME:$(find $(readlink result) -type f -name 'nixos-sd-image*') ."
