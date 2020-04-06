FROM alpine AS opam-base

RUN apk add --no-cache coreutils docker-cli gcc git m4 make musl-dev opam
RUN opam init  --compiler=4.06.0 --disable-sandboxing --dot-profile=/etc/profile.d/opam.sh --shell-setup --verbose --yes
RUN opam config set jobs $(nproc)
RUN chmod a+x /root
ENV ENV="/etc/profile"
ENV PATH="/root/.opam/4.06.0/bin:$PATH"
ARG DEPENDENCIES
RUN opam install --yes $DEPENDENCIES
