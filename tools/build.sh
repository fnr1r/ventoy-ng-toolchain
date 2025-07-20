#!/usr/bin/env bash
set -euo pipefail

HERE="$(dirname "$(readlink -f -- "$0")")"

. "$HERE/../repo.sh"

SAMPLES_DIR="$REPO_DIR/samples"

toolchains=(
    x86_64-unknown-linux-musl
    i386-unknown-linux-musl
    aarch64-unknown-linux-musl
    mips64el-unknown-linux-musl
)

#DOCKER_BUILD_DATA="/tmp/crosstool-ng"

if [ -z "${DOCKER_MODE:-}" ]; then
    DOCKER_MODE=0
fi

if [ -z "${CT_DOWNLOADS:-}" ]; then
    CT_DOWNLOADS="$REPO_DIR/src"
    export CT_DOWNLOADS
fi

if [ -z "${CT_PREFIX:-}" ]; then
    CT_PREFIX="$REPO_DIR/toolchains"
    if [ "$DOCKER_MODE" = 1 ]; then
        CT_PREFIX="/opt/ventoy-toolchain"
    fi
    export CT_PREFIX
fi

if [ -z "${TARBALLS_DIR:-}" ]; then
    TARBALLS_DIR='"${CT_DOWNLOADS:-${CT_PREFIX:-${HOME}}/src}"'
fi

eecho() {
    echo "$@" > /dev/stderr
}

arg_to_sample_str() {
    local target="$1"
    local suffixes=("" "-unknown-linux-musl")
    local sample
    for suf in "${suffixes[@]}"; do
        for ts in "${toolchains[@]}"; do
            sample="$target$suf"
            if [ "$sample" = "$ts" ]; then
                printf '%s' "$sample"
                return 0
            fi
        done
    done
    eecho "Unknown toolchain/sample $target"
    return 1
}

ct-ng-env() {
    CT_PREFIX="$CT_PREFIX" ct-ng "$@"
}

toolchain_save() {
    local sample
    sample="$(ct-ng show-tuple)"
    ct-ng-env saveconfig
    cp .config "$SAMPLES_DIR/$sample/full.config"
}

toolchain_switch() {
    local sample="$1"
    local kind="${2:-full}"
    if [ "$kind" = "full" ]; then
        cp "$SAMPLES_DIR/$sample/full.config" .config
        ct-ng upgradeconfig
        return
    fi
    ct-ng-env "$sample"
    sed \
        -E "/CT_LOCAL_TARBALLS_DIR=/cCT_LOCAL_TARBALLS_DIR=${TARBALLS_DIR}" \
        -i .config
    #echo 'CT_LOCAL_TARBALLS_DIR="${CT_DOWNLOADS:-${CT_PREFIX:-${HOME}}/src}"' > .config
    #ct-ng oldconfig
}

cmd_toolchain_save() {
    toolchain_save
}

cmd_toolchain_switch() {
    local sample
    sample="$(arg_to_sample_str "$1")"
    toolchain_switch "$sample"
}

download_one() {
    local sample="$1"
    toolchain_switch "$sample"
    local toolchain_dir="$CT_PREFIX/$sample"
    local has_toolchain
    if [ -d "$toolchain_dir" ]; then
        has_toolchain=yes
    else
        has_toolchain=no
    fi
    ct-ng-env source
    local ct_status="$?"
    if [ "$DOCKER_MODE" != 1 ]; then
        return
    fi
    if [ "$has_toolchain" = "no" ]; then
        chmod -R u+w "$toolchain_dir"
        rm -r "$toolchain_dir"
    fi
}

build_one() {
    local sample="$1"
    toolchain_switch "$sample"
    ct-ng-env build
    local ct_status="$?"
    if [ "$DOCKER_MODE" != 1 ]; then
        return "$ct_status"
    fi
    if ! [ "$ct_status" != 0 ]; then
        cat build.log
        exit "$ct_status"
    fi
    rm -r .build build.log
}

cmd_download() {
    local selected_toolchains=("${toolchains[@]}")
    for tc in "${selected_toolchains[@]}"; do
        local sample
        sample="$(arg_to_sample_str "$tc")"
        download_one "$sample"
    done
}

cmd_build() {
    local selected_toolchains=("$@")
    for tc in "${selected_toolchains[@]}"; do
        local sample
        sample="$(arg_to_sample_str "$tc")"
        build_one "$sample"
    done
}

CMD1=""
CMD2=""

cmd_toolchain() {
    CMD2="$1"
    shift
    case "$CMD2" in
        save|switch)
            "cmd_toolchain_$CMD2" "$@"
            ;;
        *)
            exit 69
            ;;
    esac
}

main() {
    CMD1="$1"
    shift
    case "$CMD1" in
        build|download)
            "cmd_$CMD1" "$@"
            ;;
        toolchain)
            cmd_toolchain "$@"
            ;;
        ct-ng)
            ct-ng-env "$@"
            ;;
        run)
            "$@"
            ;;
        *)
            exit 69
            ;;
    esac
}

_entry() {
    set -euo pipefail
    main "$@"
    eval "exit $?"
}

_entry "$@"
