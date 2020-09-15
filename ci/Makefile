TAG := $(REGISTRY)/$(NAMESPACE)/$(PROJECT)
CI_TAG := $(TAG)/ci

build:
	dune subst
	dune build

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
	test -e Dockerfile.ci && cat Dockerfile.ci >> "$(dir $(MAKEFILE_LIST))Dockerfile.ci"
	if docker pull "$(CI_TAG):$(OCAML_VERSION)"; then \
		docker build -f "$(dir $(MAKEFILE_LIST))Dockerfile.ci" . --tag "$(CI_TAG):$(OCAML_VERSION)" --cache-from "$(CI_TAG):$(OCAML_VERSION)" --build-arg OCAML_VERSION=$(OCAML_VERSION) --build-arg PACKAGES="$(PACKAGES)"; else \
		docker build -f "$(dir $(MAKEFILE_LIST))Dockerfile.ci" . --tag "$(CI_TAG):$(OCAML_VERSION)" --build-arg OCAML_VERSION=$(OCAML_VERSION) --build-arg PACKAGES="$(PACKAGES)"; fi

image/%:
	if test -e Dockerfile.$*; then cat Dockerfile.$* >> "$(dir $(MAKEFILE_LIST))Dockerfile.$*"; fi
	if docker pull "$(TAG)/$*"; then CACHE="--cache-from $(TAG)/$*"; fi; \
	docker build -f "$(dir $(MAKEFILE_LIST))Dockerfile.$*" . --tag "$(TAG)/$*" $$CACHE
