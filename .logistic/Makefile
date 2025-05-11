DOCKER_DIR=docker/dune-builder

dune-builder:
	if test -n "$(CI_ID_RSA)"; then cp "$(CI_ID_RSA)" $(DOCKER_DIR)/id_rsa; fi
	if test -n "$(CI_ID_RSA_PUB)"; then cp "$(CI_ID_RSA_PUB)" $(DOCKER_DIR)/id_rsa.pub; fi
	docker build -f $(DOCKER_DIR)/Dockerfile $(DOCKER_DIR) -t dune-builder
	IMAGE=$(CI_REGISTRY_IMAGE)/dune-builder:$$(docker run --rm dune-builder dune --version | sed 's/"//' | tail -n 1 | head -c 7) && docker tag dune-builder $$IMAGE && docker push $$IMAGE && echo "Pushed $$IMAGE"
