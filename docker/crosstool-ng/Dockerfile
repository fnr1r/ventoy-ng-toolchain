ARG VERSION=1.27.0
#ARG CHECKSUM=sha256:0506ab98fa0ad6d263a555feeb2c7fff9bc24a434635d4b0cdff9137fe5b4477

ARG ALPINE_VERSION=latest

FROM alpine:${ALPINE_VERSION} AS base

RUN --mount=type=cache,sharing=locked,target=/var/cache/apk \
    apk add \
        bash gawk lzip xz

RUN --mount=type=cache,sharing=locked,target=/var/cache/apk \
    apk add \
        ncurses

RUN --mount=type=cache,sharing=locked,target=/var/cache/apk \
    apk add \
        cvs git rsync

RUN --mount=type=cache,sharing=locked,target=/var/cache/apk \
    apk add \
        autoconf automake

RUN --mount=type=cache,sharing=locked,target=/var/cache/apk \
    apk add \
        build-base

RUN --mount=type=cache,sharing=locked,target=/var/cache/apk \
    apk add \
        bison

FROM base AS builder

ARG VERSION
#ARG CHECKSUM
ARG DIRNAME=crosstool-ng-${VERSION}
ARG FILENAME=${DIRNAME}.tar.xz

#RUN --mount=type=cache,sharing=locked,target=/var/cache/apk \
#    apk add \
#        build-base \
#        bash bison flex gawk help2man libtool ncurses ncurses-dev python3 python3-dev texinfo xz

#ADD --checksum=${CHECKSUM} \
#    http://crosstool-ng.org/download/crosstool-ng/${FILENAME} \
#    /usr/src/

#RUN tar xf /usr/src/${FILENAME} -C /usr/src

#RUN ln -sf crosstool-ng /usr/src/${DIRNAME}

ADD https://github.com/fnr1r/crosstool-ng.git#9f25ab4e9a658d93ac27d42bb34b2c05a1ddbcb4 \
    /usr/src/crosstool-ng/

RUN echo ${VERSION}-fnrir-9f25ab4e > /usr/src/crosstool-ng/.tarball-version

#ADD --checksum=sha256:a50af6ac77d851fc976089586f522cfcf24dda4ea65eabd314b7999f90d7042f \
#    https://github.com/crosstool-ng/crosstool-ng/commit/2068310ca05ef8a47a8fb31805890206428bf907.patch \
#    /usr/src/crosstool-ng-patches/0000-binutils-disable-gprofng.patch

#RUN cd /usr/src/${DIRNAME}; \
#    for patch in /usr/src/crosstool-ng-patches/*.patch; do \
#        patch -p1 -i "$patch"; \
#    done

RUN cd /usr/src/crosstool-ng \
    && bash -e bootstrap

RUN --mount=type=cache,sharing=locked,target=/var/cache/apk \
    apk add \
        flex help2man libtool texinfo

RUN --mount=type=cache,sharing=locked,target=/var/cache/apk \
    apk add \
        ncurses-dev

#RUN --mount=type=cache,sharing=locked,target=/var/cache/apk \
#    apk add \
#        python3

RUN cd /usr/src/crosstool-ng \
    && ./configure # || cat config.log && false

RUN cd /usr/src/crosstool-ng \
    && make

RUN cd /usr/src/crosstool-ng \
    && make install

FROM base

# NOTE: alpine's busybox wget confuses ct-ng
RUN --mount=type=cache,sharing=locked,target=/var/cache/apk \
    apk add wget

COPY --from=builder /usr/local /usr/local

#RUN --mount=type=cache,sharing=locked,target=/var/cache/apk \
#    apk add crosstool-ng

# no: autoconf automake bash bison
# yes: bsd-compat-headers curl
# no: flex gawk
# yes: gettext gettext-dev git help2man
# no: libtool
# yes: linux-headers ncurses ncurses-dev
# maybe: python3 python3-dev
# no: rsync texinfo wget xz

RUN --mount=type=cache,sharing=locked,target=/var/cache/apk \
    apk add \
        bsd-compat-headers

#RUN --mount=type=cache,sharing=locked,target=/var/cache/apk \
#    apk add \
#        bsd-compat-headers curl gettext gettext-dev linux-headers

#RUN --mount=type=cache,sharing=locked,target=/var/cache/apk \
#    apk add crosstool-ng
