FROM alpine:3.17.3 AS opam-base

RUN apk add --no-cache bash curl docker-cli docker-cli-buildx gcc g++ git make npm patch s3fs-fuse tzdata
RUN curl -fsSL https://get.dune.build/install | sh
ENV PATH="/root/.dune/bin:$PATH"
