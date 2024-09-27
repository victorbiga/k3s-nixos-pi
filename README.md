# k3s-nixos-pi

## Build Docker image for building micro sd card raspberry pi 4 nixos images
```bash
docker build -t sd-image-builder . --platform linux/arm64 --build-arg NODE_NAME=kube-node-1 .
docker build -t sd-image-builder . --platform linux/arm64 --build-arg NODE_NAME=kube-node-2 .
docker build -t sd-image-builder . --platform linux/arm64 --build-arg NODE_NAME=kube-node-3 .
docker build -t sd-image-builder . --platform linux/arm64 --build-arg NODE_NAME=kube-node-4 .
```
## Build raspberry pi 4 nixos image
```bash
docker run -it sd-image-builder
```

## Copy image from container
```bash
docker cp a7815e286ed0:/nix/store/s31baywpx15yk7i4zq6zd6byg9lvbi43-nixos-sd-image-23.11.20231015.12bdeb0-aarch64-linux.img/sd-image/nixos-sd-image-23.11.20231015.12bdeb0-aarch64-linux.img.zst .
```

## Decompress with zstd https://facebook.github.io/zstd/ 
```bash
zstd --decompress "nixos-sd-image-23.11.20231015.12bdeb0-aarch64-linux.img.zst"
```

Use BalenaEtcher https://etcher.balena.io/ or dd https://osxdaily.com/2018/04/18/write-image-file-sd-card-dd-command-line/ to flash micro sd card

# Join cluster
1. Login to master node.
2. cat /var/lib/rancher/k3s/server/node-token to get the token
3. Create directory /etc/k3s with `mkdir -p /etc/k3s`
4. Create file `vi /etc/k3s/token` and paste the token
5. Do `systemctl restart k3s` and check the status of the service `systemctl status k3s`
6. This step is probably not needed - Join the cluster `k3s agent --token $TOKEN --server https://10.0.0.21:6443`
