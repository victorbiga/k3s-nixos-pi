FROM nixos/nix
WORKDIR /sd-image
ARG NODE_NAME
ARG DATE_STAMP
ENV NODE_NAME=${NODE_NAME}
ENV DATE_STAMP=${DATE_STAMP}
COPY flake.nix .
COPY flake.lock .
COPY shared/ ./shared/
COPY nodes/ ./nodes/
RUN NODE_NAME="${NODE_NAME}" DATE_STAMP="${DATE_STAMP}" \
    nix --extra-experimental-features nix-command --extra-experimental-features flakes build ".#nixosConfigurations.${NODE_NAME}.config.system.build.sdImage"
RUN ls -la
RUN IMAGE_FILE_PATH=$(find "$(readlink result)" -type f -name 'nixos-image-sd-card*.img.zst') && \
    nix-shell -p coreutils gawk --run "du -h \"${IMAGE_FILE_PATH}\" | awk '{print \$1}' > image_size.txt"


SHELL ["/root/.nix-profile/bin/bash", "-c"]
ENTRYPOINT IMAGE_SIZE=$(cat image_size.txt) && \
  ACTUAL_IMAGE_PATH=$(find "$(readlink result)" -type f -name 'nixos-image-sd-card*.img.zst') && \
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
