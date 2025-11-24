# Recipies for this Makefile

## Build all docker images
##   $ make DOCKER_TAG=nightly CRYSTAL_VERSION=0.xy.z
##
## Build specific docker images
##   $ make build-ubuntu-runtime DOCKER_TAG=nightly CRYSTAL_VERSION=0.xy.z
##   $ make build-alpine-build DOCKER_TAG=nightly CRYSTAL_VERSION=0.xy.z
##
## Push all docker images to registry
##   $ make push DOCKER_TAG=nightly CRYSTAL_VERSION=0.xy.z
## Push a specific docker image to registry
##   $ make push-ubuntu-runtime DOCKER_TAG=nightly CRYSTAL_VERSION=0.xy.z
##   $ make push-alpine-build DOCKER_TAG=nightly CRYSTAL_VERSION=0.xy.z
##
## Run smoke tests
##   $ make smoke-all
##   $ make smoke-ubuntu-build
##   $ make smoke-alpine-runtime

CRYSTAL_VERSION ?=   ## How the binaries should be branded
TARBALLS ?= tarballs## Path to folder which contains the Crystal tarballs to install in docker images.

DOCKER_TAG ?= $(CRYSTAL_VERSION)## How to tag the docker image (examples: `0.27.2`, `nightly20190307`). `-build` will be appended for build images.
DOCKER_REPOSITORY ?= crystallang/crystal## Docker hub repository to commit image

BUILD_CONTEXT := build-context

.PHONY: all
all: ## Build all images
all: build-ubuntu-runtime
all: build-ubuntu-build
all: build-alpine-runtime
all: build-alpine-build

.PHONY: push
push: ## Push all images to the registry
push: push-ubuntu-runtime
push: push-ubuntu-build
push: push-alpine-runtime
push: push-alpine-build

.PHONY: push-%
push-%: build-%
	docker push $(DOCKER_REPOSITORY):$(DOCKER_TAG)$(subst -ubuntu,,-$*)

$(BUILD_CONTEXT)/crystal-amd64.tar.gz: $(TARBALLS)/crystal-$(CRYSTAL_VERSION)-1-linux-x86_64.tar.gz | $(BUILD_CONTEXT)
	cp $< $@

$(BUILD_CONTEXT):
	mkdir -p $@

.PHONY: build-%-runtime
build-%-runtime: %.Dockerfile $(BUILD_CONTEXT)/crystal-amd64.tar.gz
	docker build --file $*.Dockerfile -t $(DOCKER_REPOSITORY):$(DOCKER_TAG)$(subst -ubuntu,,-$*) --target runtime $(BUILD_CONTEXT)

.PHONY: build-%-build
build-%-build: %.Dockerfile $(BUILD_CONTEXT)/crystal-amd64.tar.gz
	docker build --file $*.Dockerfile -t $(DOCKER_REPOSITORY):$(DOCKER_TAG)$(subst -ubuntu,,-$*)-build --target build $(BUILD_CONTEXT)

alpine-84codes: ## Build and push docker build images based on the base images from 84codes
	docker buildx build --build-arg crystal_version=$(CRYSTAL_VERSION) -f alpine-84codes.Dockerfile --platform linux/amd64,linux/arm64 --tag crystallang/crystal:$(CRYSTAL_VERSION)-alpine-84codes-build --push .

ubuntu-84codes: ## Build and push docker build images based on the base images from 84codes
	docker buildx build --build-arg crystal_version=$(CRYSTAL_VERSION) -f ubuntu-84codes.Dockerfile --platform linux/amd64,linux/arm64 --tag crystallang/crystal:$(CRYSTAL_VERSION)-ubuntu-84codes-build --push .

.PHONY: smoke-all
smoke-all: ## Run smoke tests on all docker images
smoke-all: smoke-alpine
smoke-all: smoke-alpine-build
smoke-all: smoke-ubuntu
smoke-all: smoke-ubuntu-build

.PHONY: smoke-%
smoke-%: # Run smoke tests on docker images
	docker run --rm -v $(CURDIR)/smoke.sh:/smoke.sh -e CRYSTAL_VERSION=$(CRYSTAL_VERSION) $(DOCKER_REPOSITORY):$(DOCKER_TAG)$(subst -ubuntu,,-$*) /smoke.sh $*

.PHONY: clean
clean: ## Clean up build context
	rm -Rf $(BUILD_CONTEXT)

.PHONY: help
help: ## Show this help
	@echo
	@printf '\033[34mtargets:\033[0m\n'
	@grep -hE '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) |\
		sort |\
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo
	@printf '\033[34mconfiguration variables:\033[0m\n'
	@grep -hE '^[a-zA-Z0-9_-]+ \?=.*?## .*$$' $(MAKEFILE_LIST) |\
		sort |\
		awk 'BEGIN {FS = " \\?=.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo
	@printf '\033[34mrecipes:\033[0m\n'
	@grep -hE '^##.*$$' $(MAKEFILE_LIST) |\
awk 'BEGIN {FS = "## "}; /^## [a-zA-Z_-]/ {printf "  \033[36m%s\033[0m\n", $$2}; /^##  / {printf "  %s\n", $$2}'
