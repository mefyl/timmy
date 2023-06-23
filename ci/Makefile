MAKEFILE=$(abspath $(firstword $(MAKEFILE_LIST)))
DIR=$(patsubst %/,%,$(dir $(MAKEFILE)))
OCAML_VERSION ?= $(shell ocamlc --version)
DUNE=opam exec -- dune

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
	$(DUNE) build $(if ${DUNE_PACKAGES},--only-packages="${DUNE_PACKAGES}") --ignore-promoted-rules @install

lint:
	$(DUNE) build @fmt

check:
	if test -d /root/node_modules; then ln -s /root/node_modules; fi
	$(DUNE) subst
	$(DUNE) runtest $(if ${DUNE_PACKAGES},--only-packages="${DUNE_PACKAGES}")

package:
	$(DUNE) subst
	$(DUNE) install $(if ${DUNE_PACKAGES},--only-packages="${DUNE_PACKAGES}") --prefix=_install
	if ! test -e Dockerfile; then echo "FROM alpine" > Dockerfile; fi
	sed '1aADD _install/ /usr/' Dockerfile > Dockerfile.package
	docker buildx build --cache-to type=inline -f "Dockerfile.package" . -t "$(IMAGE):$$(git describe --always)"
	docker push "$(IMAGE):$$(git describe --always)"
	docker tag "$(IMAGE):$$(git describe --always)" "$(IMAGE):$$SLUG"
	docker push "$(IMAGE):$$SLUG"
	echo "docker-image \"$(IMAGE):$$(git describe --always)\"" > metrics.txt

package/clean:
	docker rmi "$(IMAGE):$$(git describe --always)" "$(IMAGE):$$SLUG"

ci/image:
	if test -n "$(CI_ID_RSA)"; then cp "$(CI_ID_RSA)" $(DOCKER_DIR)/id_rsa; fi
	if test -n "$(CI_ID_RSA_PUB)"; then cp "$(CI_ID_RSA_PUB)" $(DOCKER_DIR)/id_rsa.pub; fi
	if test -z "$$FROM_SCRATCH" && ! test -z "$(IMAGE_CI)"; then \
		CACHE='--cache-from "$(IMAGE_CI)$(VARIANT)" --cache-from "$(IMAGE_CI_MASTER)$(VARIANT)" --cache-from "$(IMAGE_CI_MASTER)"'; \
	else \
		echo "building from scratch"; \
		CACHE='--no-cache'; \
	fi; \
	if ! test -z "$$SSH_AUTH_SOCK"; then \
	        DOCKER_SSH="--ssh default"; \
	fi ; \
	if test -n "$(DOCKER_TARGET)"; then DOCKER_TARGET="--target $(DOCKER_TARGET)"; fi; \
	docker buildx build $$DOCKER_SSH --cache-to type=inline -f "$(DOCKER_FILE)" "$(DOCKER_DIR)" $$DOCKER_TARGET --tag "$(or $(IMAGE_CI)$(VARIANT),ci)" --build-arg OCAML_VERSION=$(OCAML_VERSION) --build-arg PACKAGES="$(PACKAGES)" --build-arg OPAM_PACKAGES="$(OPAM_PACKAGES)" --build-arg OPAM_WITHOUT_PACKAGES="$(OPAM_WITHOUT_PACKAGES)" --build-arg AWS_SECRET_ACCESS_KEY="$(AWS_SECRET_ACCESS_KEY)" --build-arg CI_VARIANT=$(subst -,,$(VARIANT)) $$CACHE

image/%:
	if test -n "$(FROM_SCRATCH)"; then CACHE="--no-cache"; \
	else if docker pull "$(IMAGE)/$*"; then CACHE="--cache-from $(IMAGE)/$*"; fi; \
	fi; \
	docker buildx build --cache-to type=inline -f "Dockerfile.$*" . --tag "$(IMAGE)/$*" $$CACHE --build-arg PACKAGES="$(PACKAGES)"

opam:
	$(DIR)/opam-publish
