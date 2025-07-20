alpine_ver := "3.22.1"

# --build-arg "ALPINE_VERSION="

ct_tag := "ghcr.io/fnr1r/ventoy-ng-toolchain/crosstool-ng:latest"
vt_tag := "ghcr.io/fnr1r/ventoy-ng-toolchain/toolchain-alpine:latest"

build-ct:
    docker build --build-arg "ALPINE_VERSION={{ alpine_ver }}" -t {{ ct_tag }} docker/crosstool-ng

download:
    ./tools/build.sh download

build:
    ./tools/build.sh build

build-in-docker:
    docker build --build-arg "ALPINE_VERSION={{ alpine_ver }}" -t {{ vt_tag }} . -f docker/ventoy-ng-toolchain/Dockerfile
