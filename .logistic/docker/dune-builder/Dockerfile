FROM alpine:3.23.2 AS opam-base

RUN apk add --no-cache autoconf bash curl docker-cli docker-cli-buildx gcc g++ git make npm openssh patch tzdata zlib-dev zstd-libs

# Enable pushing to git@gitlab.routine.co:routine/opam
ADD id_rsa* /root/.ssh/
RUN if test -e /root/.ssh/id_rsa; then chmod 600 /root/.ssh/id_rsa; else mkdir -p /root/.ssh; fi
RUN ssh-keyscan gitlab.routine.co > /root/.ssh/known_hosts

RUN curl -fsSL https://get.dune.build/install | sh -s - --release 3.22.2
ADD dune-config /root/.config/dune/config
ENV PATH=/root/.local/bin:$PATH
