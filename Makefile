default: help

help: ## display this message
	@grep -E '(^[a-zA-Z0-9_.-]+:.*?##.*$$)|(^##)' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

DOCKER_IMAGE = docker.io/bill-of-materials/clockworks:latest

# could be just `docker build` too
build_command = docker buildx build

docker: ## build the docker artifact
	$(build_command) -t $(DOCKER_IMAGE) .

tg2: docker ## extract tg2 binary from docker artifact
	@docker create -it --name tg2 "$(DOCKER_IMAGE)" sh
	@docker cp tg2:/app/tg2 tg2
	@docker rm tg2
	@chmod +x ./tg2

clean: ## cleanup docker image and binary
	@rm ./tg2 2>/dev/null || true
	@docker rm tg2 2>/dev/null || true
	@docker image rm "${DOCKER_IMAGE}" 2>/dev/null || true

run: ## start tg2
	./tg2 -x

start: run ## start tg2

all: tg2 ## build container and extract artifact
build: tg2 ## build container and extract artifact
