.PHONY: opam
MAKEFILE=$(abspath $(firstword $(MAKEFILE_LIST)))
DIR=$(patsubst %/,%,$(dir $(MAKEFILE)))
OCAML_VERSION ?= $(shell ocamlc --version)
DUNE=dune

-include Makefile.ci

ifdef DOCKERFILE_BASE
DOCKERFILE_SUFFIX=.$(DOCKERFILE_BASE)
endif

DOCKER_DIR := .
ifndef DOCKER_FILE
DOCKER_FILE := $(dir $(firstword $(MAKEFILE_LIST)))Dockerfile.ci$(DOCKERFILE_SUFFIX)
endif

build:
	if test -d /root/node_modules; then ln -s /root/node_modules; fi
	$(DUNE) subst
	$(DUNE) build --profile release $(if ${DUNE_PACKAGES},--only-packages="${DUNE_PACKAGES}") --ignore-promoted-rules @install

lint:
	$(DUNE) build @fmt

check:
	if test -d /root/node_modules; then ln -s /root/node_modules; fi
	$(DUNE) subst
	$(DUNE) runtest $(if ${DUNE_PACKAGES},--only-packages="${DUNE_PACKAGES}")

package:
	$(DUNE) subst
	$(DUNE) install $(if ${DUNE_PACKAGES},--only-packages="${DUNE_PACKAGES}") --prefix=_install
	if ! test -e Dockerfile; then echo "FROM alpine:3.21.0" > Dockerfile; fi
	sed '1aADD _install/ /usr/' Dockerfile > Dockerfile.package
	docker buildx build --cache-to type=inline -f "Dockerfile.package" . -t "$(IMAGE):$$(git describe --always)"
	docker push "$(IMAGE):$$(git describe --always)"
	docker tag "$(IMAGE):$$(git describe --always)" "$(IMAGE):$$SLUG"
	docker push "$(IMAGE):$$SLUG"
	echo "Pushed Docker image: \"$(IMAGE):$$(git describe --always)\"" 
	docker rmi "$(IMAGE):$$(git describe --always)" "$(IMAGE):$$SLUG"

image/%:
	if docker buildx inspect builder; then \
		CACHE="--builder=builder --cache-to type=inline --push "; \
	fi; \
	if test -n "$(FROM_SCRATCH)"; then CACHE="--no-cache"; \
	else CACHE="$$CACHE--cache-from type=registry,ref=$(IMAGE)/$*"; \
	fi; \
	docker buildx build -f "Dockerfile.$*" . --tag "$(IMAGE)/$*" $$CACHE --build-arg PACKAGES="$(PACKAGES)"

opam:
	$(DIR)/opam-publish

select-track:
	if test -n "$$TRACK"; then \
		echo "(context (default (lock_dir $(TRACK).lock)))" \
		>> dune-workspace ; \
		echo "Select track $$TRACK." ; \
	fi
