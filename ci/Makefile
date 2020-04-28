CI_TAG := $(REGISTRY)/$(NAMESPACE)/$(PROJECT)/ci

build:
	dune build

check:
	dune runtest

ci/image:
	docker build -f "$(dir $(MAKEFILE_LIST))Dockerfile" . -t $(CI_TAG):$(OCAML_VERSION) --build-arg OCAML_VERSION=$(OCAML_VERSION) --build-arg PACKAGES=$(PACKAGES)
