OCAML_VERSION ?= $(shell ocamlc --version)
IMAGE_CI ?= front/ci

build: lint
	dune subst
	dune build

lint:
	dune build @fmt

check:
	dune subst
	dune runtest

package:
	dune subst
	dune install --prefix=_install
	if ! test -e Dockerfile; then echo "FROM alpine" > Dockerfile; fi
	sed '1aADD _install/ /usr/' Dockerfile > Dockerfile.package
	docker build -f "Dockerfile.package" . -t "$(IMAGE):$$(git describe --always)"
	docker push "$(IMAGE):$$(git describe --always)"
	docker tag "$(IMAGE):$$(git describe --always)" "$(IMAGE):$$SLUG"
	docker push "$(IMAGE):$$SLUG"
	echo "docker-image \"$(IMAGE):$$(git describe --always)\"" > metrics.txt

package/clean:
	docker rmi "$(IMAGE):$$(git describe --always)" "$(IMAGE):$$SLUG"

ci/image:
	if test -e Dockerfile.ci; then cat Dockerfile.ci >> "$(dir $(MAKEFILE_LIST))Dockerfile.ci"; fi
	if test -z "$$FROM_SCRATCH"; then \
		if docker pull "$(IMAGE_CI):$(OCAML_VERSION)"; then \
			echo "using remote $(CI_COMMIT_REF_NAME) cache";  \
	                CACHE='--cache-from "$(IMAGE_CI):$(OCAML_VERSION)"' ; \
		elif docker pull "$(IMAGE_CI_MASTER):$(OCAML_VERSION)"; then \
			echo "using remote master cache"; \
			CACHE='--cache-from "$(IMAGE_CI_MASTER):$(OCAML_VERSION)"'; \
		else \
			echo "using local cache"; \
			CACHE=''; \
	        fi; \
	else \
		echo "building from scratch"; \
		CACHE='--no-cache'; \
	fi; \
	docker build -f "$(dir $(MAKEFILE_LIST))Dockerfile.ci" . --tag "$(IMAGE_CI):$(OCAML_VERSION)" --build-arg OCAML_VERSION=$(OCAML_VERSION) --build-arg PACKAGES="$(PACKAGES)" --build-arg AWS_SECRET_ACCESS_KEY="$(AWS_SECRET_ACCESS_KEY)" $$CACHE

image/%:
	if test -e Dockerfile.$*; then cat Dockerfile.$* >> "$(dir $(MAKEFILE_LIST))Dockerfile.$*"; fi
	if test -n "$(FROM_SCRATCH)"; then CACHE="--no-cache"; \
	else if docker pull "$(IMAGE)/$*"; then CACHE="--cache-from $(IMAGE)/$*"; fi; \
	fi; \
	docker build -f "$(dir $(MAKEFILE_LIST))Dockerfile.$*" . --tag "$(IMAGE)/$*" $$CACHE

opam:
	git clone --depth 1 git@gitlab.routine.co:routine/opam /tmp/opam
	$(eval FILE := $(CI_PROJECT_NAME).$(CI_COMMIT_TAG))
	$(eval PKG_PATH := /tmp/opam/packages/$(CI_PROJECT_NAME)/$(FILE))
	dune build "$(FILE).opam"
	mkdir -p "$(PKG_PATH)"
	cp "_build/default/$(FILE).opam" "$(PKG_PATH)/opam"
	git -C "/tmp/opam" add $(PKG_PATH)/opam
	GIT_COMMITTER_EMAIL="$$(echo '$(CI_COMMIT_AUTHOR)' | sed 's/^.* <\(.*\)>$$/\1/')" GIT_COMMITTER_NAME="$$(echo '$(CI_COMMIT_AUTHOR)' | sed 's/ <.*>$$//')" git -C "/tmp/opam" commit --author="$(CI_COMMIT_AUTHOR)" --message="Add $(FILE)."
	git -C "/tmp/opam" push
