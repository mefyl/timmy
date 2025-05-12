.PHONY: opam
MAKEFILE=$(abspath $(firstword $(MAKEFILE_LIST)))
DIR=$(patsubst %/,%,$(dir $(MAKEFILE)))
DUNE := dune
WORKSPACE_OPT := $(if $(WORKSPACE),--workspace dune-workspace.$(WORKSPACE),)

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
	$(DUNE) build --profile release $(WORKSPACE_OPT) --ignore-promoted-rules @install

lint:
	$(DUNE) build $(WORKSPACE_OPT) @fmt

check:
	if test -d /root/node_modules; then ln -s /root/node_modules; fi
	$(DUNE) subst
	$(DUNE) runtest $(WORKSPACE_OPT)

package:
	$(DUNE) subst
	$(DUNE) install $(WORKSPACE_OPT) --prefix=_install
	if ! test -e Dockerfile; then echo "FROM alpine:3.21.0" > Dockerfile; fi
	sed '1aADD _install/ /usr/' Dockerfile > Dockerfile.package
	docker buildx build --cache-to type=inline -f "Dockerfile.package" . -t "$(IMAGE):$$(git describe --always)"
	docker push "$(IMAGE):$$(git describe --always)"
	docker tag "$(IMAGE):$$(git describe --always)" "$(IMAGE):$$SLUG"
	docker push "$(IMAGE):$$SLUG"
	echo "Pushed Docker image: \"$(IMAGE):$$(git describe --always)\"" 
	docker rmi "$(IMAGE):$$(git describe --always)" "$(IMAGE):$$SLUG"

opam:
	$(DIR)/opam-publish
