FROM nixos/nix
WORKDIR /sd-image

# Arguments
ARG NODE_NAME
ENV NODE_NAME=${NODE_NAME}

# Copy files and build the SD image
COPY flake.nix .
COPY flake.lock .
COPY shared/ ./shared/
COPY nodes/ ./nodes/

RUN nix --extra-experimental-features nix-command --extra-experimental-features flakes build ".#nixosConfigurations.${NODE_NAME}.config.system.build.sdImage"

# Find the built image and save its path and size to files
# This runs in a standard shell, e.g., /bin/sh
RUN IMAGE_FILE_PATH=$(find "$(readlink result)" -type f -name '*.img.zst') && \
    echo "${IMAGE_FILE_PATH}" > image_path.txt && \
    nix-shell -p coreutils gawk --run "du -h \"${IMAGE_FILE_PATH}\" | awk '{print \$1}'" > image_size.txt

# The ENTRYPOINT will now run with the default shell (/bin/sh)
ENTRYPOINT ACTUAL_IMAGE_PATH=$(cat image_path.txt) && \
           IMAGE_SIZE=$(cat image_size.txt) && \
           echo '✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨' && \
           echo '✨ Your NixOS SD image is ready!  ✨' && \
           echo '✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨' && \
           echo "" && \
           echo "The image file is located at:" && \
           echo "${ACTUAL_IMAGE_PATH} inside this container." && \
           echo "" && \
           echo "The compressed image size is: ~${IMAGE_SIZE}" && \
           echo "" && \
           echo "To copy it to your host, run this command in your terminal:" && \
           echo "" && \
           echo "docker cp $HOSTNAME:${ACTUAL_IMAGE_PATH} ." && \
           echo "" && \
           echo "Happy flashing! 🚀"
