FROM alpine:3.23.2 AS opam-base

RUN apk add --no-cache autoconf bash curl docker-cli docker-cli-buildx gcc g++ git make npm opam openssh patch tzdata zlib-dev zstd-libs

# Enable pushing to git@gitlab.routine.co:routine/opam
ADD id_rsa* /root/.ssh/
RUN if test -e /root/.ssh/id_rsa; then chmod 600 /root/.ssh/id_rsa; else mkdir -p /root/.ssh; fi
RUN ssh-keyscan gitlab.routine.co > /root/.ssh/known_hosts

# Install the Dune Developer Preview version to be able to use `dune
# pkg` instead of `opam`

# Install a predetermined dune version.
RUN opam init --disable-sandboxing --dot-profile=/etc/profile.d/opam.sh --shell-setup --verbose --yes && opam install dune.3.21.0
ENV PATH=/root/.opam/default/bin:$PATH
