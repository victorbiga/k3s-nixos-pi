# k3s-nixos-pi

This project is focused on building NixOS images for Raspberry Pi 4 and Raspberry Pi 5, configured to join a k3s Kubernetes cluster.

---

## **Building the Docker Image for NixOS Raspberry Pi 4 MicroSD Card**

You can build multiple Raspberry Pi images with different node names by executing the following commands:

```
# Build Docker image for kube-node-1
docker build -t sd-image-builder --platform linux/arm64 --build-arg NODE_NAME=kube-node-1 .

# Build Docker image for kube-node-2
docker build -t sd-image-builder --platform linux/arm64 --build-arg NODE_NAME=kube-node-2 .

# Build Docker image for kube-node-3
docker build -t sd-image-builder --platform linux/arm64 --build-arg NODE_NAME=kube-node-3 .

# Build Docker image for kube-node-4
docker build -t sd-image-builder --platform linux/arm64 --build-arg NODE_NAME=kube-node-4 .
```

## **Building the Raspberry Pi 4 NixOS Image**

After the image is built, you can extract it from the Docker container. First, find the container ID (replace a7815e286ed0 with the correct one), then run:

```
docker run -it sd-image-builder
```

## **Copying the Image from the Docker Container**
```
docker cp a7815e286ed0:/nix/store/s31baywpx15yk7i4zq6zd6byg9lvbi43-nixos-sd-image-23.11.20231015.12bdeb0-aarch64-linux.img/sd-image/nixos-sd-image-23.11.20231015.12bdeb0-aarch64-linux.img.zst .
```

## **Decompressing the Image**

The image is compressed with [Zstandard (zstd)](https://facebook.github.io/zstd/). To decompress it:

```
zstd --decompress "nixos-sd-image-23.11.20231015.12bdeb0-aarch64-linux.img.zst"
```

## **Flashing the MicroSD Card**

Once decompressed, you can flash the image to a microSD card using one of the following methods:

- **[Balena Etcher](https://etcher.balena.io/)**: A simple GUI tool to flash OS images onto drives.
- **Using `dd` via the command line**: Follow this [guide](https://osxdaily.com/2018/04/18/write-image-file-sd-card-dd-command-line/).

## **Joining the Cluster**

To join your Raspberry Pi node to an existing k3s Kubernetes cluster, follow these steps:

1. **Log in to the master node**:  
   Connect to the master node where the k3s server is running.

2. **Retrieve the k3s token**:  
   Run the following command on the master node to get the token required for joining the cluster:

   ```
   cat /var/lib/rancher/k3s/server/node-token
   ```
   
3.	**Create the necessary directory on the Raspberry Pi**:
    On the Raspberry Pi node, create the /etc/k3s directory:

    ```
    mkdir -p /etc/k3s
    ```
    
4.	**Store the token on the Raspberry Pi**:
    Paste the token retrieved from the master node into a file called token in the /etc/k3s/ directory:

  	```
    vi /etc/k3s/token
    ```
   
5.	**Restart the k3s service**:
    After saving the token, restart the k3s service and check its status to ensure it’s running correctly:

  	```
    systemctl restart k3s
    systemctl status k3s
    ```
   
6.	(Optional) **Manually join the cluster**:
    If the node doesn’t automatically join the cluster, you can manually run the following command, replacing $TOKEN with the actual token, and 10.0.0.21:6443 with the correct IP address and port of your k3s server:
  	```
    k3s agent --token $TOKEN --server https://10.0.0.21:6443
    ```

### **Useful Resources**

- [k3s Documentation](https://k3s.io/)
- [NixOS Documentation](https://nixos.org/manual/nixos/stable/)
- [Zstandard Compression](https://facebook.github.io/zstd/)
- [Balena Etcher](https://etcher.balena.io/)
