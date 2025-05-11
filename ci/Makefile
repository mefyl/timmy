.PHONY: opam
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
	$(DUNE) build --profile release $(if ${DUNE_PACKAGES},--only-packages="${DUNE_PACKAGES}") --ignore-promoted-rules @install

# `opam-dune-lint` does not correctly honor the global switch set via OPAMSWITCH env var, so as a workaround, we symlink `_opam`
# See https://discuss.ocaml.org/t/opam-dune-lint-fails-on-bare-opam-initialization/16045/2
lint:
	ln -s /root/_opam _opam
	opam exec -- opam-dune-lint
	rm _opam
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
	echo "$(IMAGE):$$(git describe --always)"
	docker push "$(IMAGE):$$(git describe --always)"
	docker tag "$(IMAGE):$$(git describe --always)" "$(IMAGE):$$SLUG"
	echo "$(IMAGE):$$SLUG"
	docker push "$(IMAGE):$$SLUG"

package/clean:
	docker rmi "$(IMAGE):$$(git describe --always)" "$(IMAGE):$$SLUG"

toolchain/%:
	$(eval SUFFIX = $(if $(filter $*,default),,.$*))
	if test -n "$(CI_ID_RSA)"; then cp "$(CI_ID_RSA)" $(DOCKER_DIR)/id_rsa; fi
	if test -n "$(CI_ID_RSA_PUB)"; then cp "$(CI_ID_RSA_PUB)" $(DOCKER_DIR)/id_rsa.pub; fi
	set -x; \
	if ! test -z "$(IMAGE_CI)"; then \
		if docker buildx inspect builder; then \
			CACHE="--builder=builder --cache-to type=inline --push "; \
		fi; \
		if test -z "$$FROM_SCRATCH"; then \
			for image in "$(IMAGE_CI)$(VARIANT)$(SUFFIX)" "$(IMAGE_CI_MASTER)$(VARIANT)$(SUFFIX)" "$(IMAGE_CI_MASTER)$(SUFFIX)"; do \
				CACHE="$$CACHE--cache-from type=registry,ref=$$image "; \
			done; \
		else \
			echo "building from scratch"; \
			CACHE="$$CACHE--no-cache"; \
		fi; \
	fi; \
	if ! test -z "$$SSH_AUTH_SOCK"; then \
	        DOCKER_SSH="--ssh default"; \
	fi ; \
	if test -n "$(DOCKER_TARGET)"; then DOCKER_TARGET="--target $(DOCKER_TARGET)"; fi; \
	docker buildx build $$DOCKER_SSH -f "$(DOCKER_FILE)$(SUFFIX)" "$(DOCKER_DIR)" $$DOCKER_TARGET --tag "$(or $(IMAGE_CI)$(VARIANT)$(SUFFIX),ci)" --build-arg OCAML_VERSION=$(OCAML_VERSION) --build-arg PACKAGES="$(PACKAGES)" --build-arg OPAM_PACKAGES="$(OPAM_PACKAGES)" --build-arg OPAM_WITHOUT_PACKAGES="$(OPAM_WITHOUT_PACKAGES)" --build-arg AWS_SECRET_ACCESS_KEY="$(AWS_SECRET_ACCESS_KEY)" --build-arg CI_VARIANT=$(subst -,,$(VARIANT)) --build-arg CI_IMAGE="$(CI_IMAGE)" --build-arg ARCH=$(ARCH) $$CACHE

toolchain: toolchain/default

# Backward compatibility
ci/image: toolchain

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
