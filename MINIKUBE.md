https://itnext.io/using-minikube-on-m1-macs-416da593ba0c

# Minikube on M1 Mac

## Running for the first time

```shell
brew install podman
brew install minikube
```

```shell
podman machine init --cpus 2 --memory 2048 --rootful
podman machine start
```

```shell
minikube start --driver=podman
```

## Restarting

```shell
podman machine start
```

```shell
minikube start --driver=podman
```

## Issues

The `skaffold run` command can fail on the Jib build with the following error

```shell
 the configured platform (arm64/linux) doesn't match the platform (amd64/linux) of the base image (gcr.io/distroless/java:11)
```

Fix by specifying a platform: `skaffold run--platform linux/amd64`.
