TAG := $(REGISTRY)/$(NAMESPACE)/$(PROJECT)
CI_TAG := $(TAG)/ci

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
	docker build -f "Dockerfile.package" . -t "$(TAG):$$(git describe --always)"
	docker push "$(TAG):$$(git describe --always)"
	docker tag "$(TAG):$$(git describe --always)" "$(TAG):$$SLUG"
	docker push "$(TAG):$$SLUG"
	echo "docker-image \"$(TAG):$$(git describe --always)\"" > metrics.txt

package/clean:
	docker rmi "$(TAG):$$(git describe --always)"

ci/image:
	if test -e Dockerfile.ci; then cat Dockerfile.ci >> "$(dir $(MAKEFILE_LIST))Dockerfile.ci"; fi
	if test -z "$$FROM_SCRATCH"; then \
		if docker pull "$(CI_TAG):$(OCAML_VERSION)"; then \
			docker build -f "$(dir $(MAKEFILE_LIST))Dockerfile.ci" . --tag "$(CI_TAG):$(OCAML_VERSION)" --cache-from "$(CI_TAG):$(OCAML_VERSION)" --build-arg OCAML_VERSION=$(OCAML_VERSION) --build-arg PACKAGES="$(PACKAGES)"; else \
			docker build -f "$(dir $(MAKEFILE_LIST))Dockerfile.ci" . --tag "$(CI_TAG):$(OCAML_VERSION)" --build-arg OCAML_VERSION=$(OCAML_VERSION) --build-arg PACKAGES="$(PACKAGES)"; fi; else \
		docker build -f "$(dir $(MAKEFILE_LIST))Dockerfile.ci" . --no-cache --tag "$(CI_TAG):$(OCAML_VERSION)" --build-arg OCAML_VERSION=$(OCAML_VERSION) --build-arg PACKAGES="$(PACKAGES)"; fi

image/%:
	if test -e Dockerfile.$*; then cat Dockerfile.$* >> "$(dir $(MAKEFILE_LIST))Dockerfile.$*"; fi
	if docker pull "$(TAG)/$*"; then CACHE="--cache-from $(TAG)/$*"; fi; \
	docker build -f "$(dir $(MAKEFILE_LIST))Dockerfile.$*" . --tag "$(TAG)/$*" $$CACHE
