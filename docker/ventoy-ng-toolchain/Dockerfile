ARG ALPINE_VERSION=latest

FROM ghcr.io/fnr1r/ventoy-ng-toolchain/crosstool-ng:latest AS builder

RUN addgroup -g 1000 builder
RUN adduser -D -u 1000 -G builder builder wheel
RUN for dir in /build /opt/ventoy-toolchain; do mkdir $dir; chown builder: $dir; done

RUN --mount=type=cache,sharing=locked,target=/var/cache/apk \
    apk add \
        doas just wget

USER builder

WORKDIR /build
COPY samples /build/samples
COPY tools /build/tools
COPY repo.sh /build/repo.sh
ENV DOCKER_MODE=1
RUN mkdir src
RUN --mount=type=cache,uid=1000,gid=1000,target=/build/src \
    bash tools/build.sh download
RUN --mount=type=cache,uid=1000,gid=1000,target=/build/src \
    bash tools/build.sh build x86_64-unknown-linux-musl
RUN --mount=type=cache,uid=1000,gid=1000,target=/build/src \
    bash tools/build.sh build i386-unknown-linux-musl
RUN --mount=type=cache,uid=1000,gid=1000,target=/build/src \
    bash tools/build.sh build aarch64-unknown-linux-musl
RUN --mount=type=cache,uid=1000,gid=1000,target=/build/src \
    bash tools/build.sh build mips64el-unknown-linux-musl

USER root

RUN chown -R root:root /opt/ventoy-toolchain

RUN --mount=type=cache,sharing=locked,target=/var/cache/apk \
    apk add \
        nano ncdu

FROM alpine:${ALPINE_VERSION}

COPY --from=builder /opt/ventoy-toolchain /opt/ventoy-toolchain
