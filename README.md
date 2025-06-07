# k3s-nixos-pi 🚀

A project to build NixOS images for Raspberry Pi 4 and 5, configured to join a k3s Kubernetes cluster.

## Building the Docker Image 🐳

This Docker image is used to build the NixOS image for the Raspberry Pi.

The following table shows the different node names and their corresponding build commands:

| Node Name           | Build Command                                                                                                                      |
| ------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| kube-node-1 (RPi 4) | `docker build --build-arg NODE_NAME=kube-node-1 --build-arg DATE_STAMP=$(date +%Y-%m-%d-%H-%M) -t kube-node-1 -- progress=plain .` |
| kube-node-2 (RPi 4) | `docker build --build-arg NODE_NAME=kube-node-2 --build-arg DATE_STAMP=$(date +%Y-%m-%d-%H-%M) -t kube-node-2 -- progress=plain .` |
| kube-node-3 (RPi 4) | `docker build --build-arg NODE_NAME=kube-node-3 --build-arg DATE_STAMP=$(date +%Y-%m-%d-%H-%M) -t kube-node-3 -- progress=plain .` |
| kube-node-4 (RPi 4) | `docker build --build-arg NODE_NAME=kube-node-4 --build-arg DATE_STAMP=$(date +%Y-%m-%d-%H-%M) -t kube-node-4 -- progress=plain .` |
| kube-node-5 (RPi 5) | `docker build --build-arg NODE_NAME=kube-node-5 --build-arg DATE_STAMP=$(date +%Y-%m-%d-%H-%M) -t kube-node-5 -- progress=plain .` |
| kube-node-6 (RPi 5) | `docker build --build-arg NODE_NAME=kube-node-6 --build-arg DATE_STAMP=$(date +%Y-%m-%d-%H-%M) -t kube-node-6 -- progress=plain .` |

The `NODE_NAME` argument specifies the name of the node to build the image for. The `DATE_STAMP` argument is used to stamp the image with the current date.

## Building the Raspberry Pi NixOS Image 🍓

After building the Docker image, run this command to see the docker cp command in order to copy the build image:

```
docker run kube-node-1
```

## Copying the Image from the Docker Container 💾

To copy the image from the Docker container to your host machine, first run the container and check the output. You should see something like this:

```
✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨
✨ Your NixOS SD image is ready!  ✨
✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨

The image file is located at:
/nix/store/1avyf283xyfrqnda2fi87jsqwv2kcmas-nixos-image-sd-card-25.11.20250519.9bd9c72-aarch64-linux.img.zst/sd-image/nixos-image-sd-card-25.11.20250519.9bd9c72-aarch64-linux.img.zst inside this container.

The compressed image size is: ~1.4G

To copy it to your host, run this command in your terminal:

docker cp a00fbca02dc0:/nix/store/1avyf283xyfrqnda2fi87jsqwv2kcmas-nixos-image-sd-card-25.11.20250519.9bd9c72-aarch64-linux.img.zst/sd-image/nixos-image-sd-card-25.11.20250519.9bd9c72-aarch64-linux.img.zst .

Happy flashing! 🚀
```

Then, use the `docker cp` command from the output to copy the image. The image is located in the `/nix/store` directory inside the container, as defined in the `Dockerfile`.

## Decompressing the Image 📦

The image is compressed with [Zstandard (zstd)](https://facebook.github.io/zstd/), a fast lossless compression algorithm. To decompress it:

```
zstd --decompress "nixos-image-sd-card-25.11.20250519.9bd9c72-aarch64-linux.img.zst"
```

## Flashing the MicroSD Card ⚡️

Once decompressed, you can flash the image to a microSD card using one of the following methods:

- [Balena Etcher](https://etcher.balena.io/): A simple GUI tool to flash OS images onto drives.
- Using `dd` via the command line: Follow this [guide](https://osxdaily.com/2018/04/18/write-image-file-sd-card-dd-command-line/).

## Joining the Cluster 🤝

To join your Raspberry Pi node to an existing k3s Kubernetes cluster:

1.  Log in to the master node:
    Connect to the master node where the k3s server is running.
2.  Retrieve the k3s token:
    Run the following command on the master node to get the token required for joining the cluster:

    ```
    cat /var/lib/rancher/k3s/server/node-token
    ```

3.  Create the necessary directory on the Raspberry Pi:
    On the Raspberry Pi node, create the `/etc/k3s` directory:

    ```
    mkdir -p /etc/k3s
    ```

4.  Store the token on the Raspberry Pi:
    Paste the token retrieved from the master node into a file called `token` in the `/etc/k3s/` directory:

    ```
    vi /etc/k3s/token
    ```

5.  Restart the k3s service:
    After saving the token, restart the k3s service and check its status to ensure it’s running correctly:

    ```
    systemctl restart k3s
    systemctl status k3s
    ```

6.  (Optional) Manually join the cluster:
    If the node doesn’t automatically join the cluster, you can manually run the following command, replacing `$TOKEN` with the actual token, and `10.0.0.21:6443` with the correct IP address and port of your k3s server:

    ```
    k3s agent --token $TOKEN --server https://10.0.0.21:6443
    ```

## Useful Resources 📚

- [k3s Documentation](https://k3s.io/)
- [NixOS Documentation](https://nixos.org/manual/nixos/stable/)
- [Zstandard Compression](https://facebook.github.io/zstd/)
- [Balena Etcher](https://etcher.balena.io/)
- [k3s Community](https://k3s.io/community/)
- [NixOS Community](https://nixos.org/community/)

## Contributing 💖

Contributions are welcome! Please feel free to submit a pull request.

## License 📝

This project is licensed under the [MIT License](LICENSE).
