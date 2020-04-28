FROM alpine AS opam-base

RUN apk add --no-cache coreutils docker-cli gcc git m4 make musl-dev opam
ARG OCAML_VERSION
RUN opam init  --compiler="$OCAML_VERSION" --disable-sandboxing --dot-profile=/etc/profile.d/opam.sh --shell-setup --verbose --yes
RUN opam config set jobs $(nproc)
RUN chmod a+x /root
ENV ENV="/etc/profile"
ENV PATH="/root/.opam/$OCAML_VERSION/bin:$PATH"
ADD *.opam /root
RUN opam install --yes --deps-only /root
ARG PACKAGES
RUN test -n "$PACKAGES" && apk add --no-cache "$PACKAGES"
