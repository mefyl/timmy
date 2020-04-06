CI_TAG := $(REGISTRY)/$(NAMESPACE)/$(PROJECT)/ci

build:
	dune build

check:
	dune runtest

dependencies/install:
	DEPS=$$($(MAKE) -f $(MAKEFILE_LIST) --no-print-directory dependencies/list) && opam install --yes $$DEPS

dependencies/list:
	@dune external-lib-deps @@default 2>1 | sed -n 's/- //p' | grep -v '\.'

ci/image:
	docker build -f "$(dir $(MAKEFILE_LIST))Dockerfile" . -t $(CI_TAG) --build-arg DEPENCENCIES="$$(cat .opam-deps)"
