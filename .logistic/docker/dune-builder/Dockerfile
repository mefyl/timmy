FROM alpine:3.21.0 AS opam-base

RUN apk add --no-cache autoconf bash curl docker-cli docker-cli-buildx gcc g++ git make npm openssh patch tzdata zlib-dev zstd-libs

# Enable pushing to git@gitlab.routine.co:routine/opam
ADD id_rsa* /root/.ssh/
RUN if test -e /root/.ssh/id_rsa; then chmod 600 /root/.ssh/id_rsa; else mkdir -p /root/.ssh; fi
RUN ssh-keyscan gitlab.routine.co > /root/.ssh/known_hosts

# Install the Dune Developer Preview version to be able to use `dune
# pkg` instead of `opam`

# Stay on a predetermined dune version.
RUN curl -fsSL https://get.dune.build/install | sed 's#^dune_tar_uri=.*#dune_tar_uri="https://get.dune.build/2025-06-21/$target/dune-2025-06-21-$target.tar.gz"#' | sh
ADD dune-config /root/.config/dune/config
ENV PATH="/root/.local/bin:$PATH"
