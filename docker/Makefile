# Recipies for this Makefile

## Build all docker images
##   $ make DOCKER_TAG=nightly CRYSTAL_VERSION=0.xy.z
## Build ubuntu64 docker images
##   $ make ubuntu64 DOCKER_TAG=nightly CRYSTAL_VERSION=0.xy.z
## Build alpine docker images
##   $ make alpine DOCKER_TAG=nightly CRYSTAL_VERSION=0.xy.z

CRYSTAL_VERSION ?=   ## How the binaries should be branded
TARBALLS ?= tarballs## Path to folder which contains the Crystal tarballs to install in docker images.

DOCKER_TAG ?= $(CRYSTAL_VERSION)## How to tag the docker image (examples: `0.27.2`, `nightly20190307`). `-build` will be appended for build images.
DOCKER_REPOSITORY ?= crystallang/crystal## Docker hub repository to commit image

OUTPUT_DIR := build
BUILD_CONTEXT := build-context
DOCKER_TAG_UBUNTU := $(DOCKER_REPOSITORY):$(DOCKER_TAG)
DOCKER_TAG_ALPINE := $(DOCKER_REPOSITORY):$(DOCKER_TAG)-alpine

.PHONY: all64
all64: ubuntu64 alpine ## Build all x86_64 images

.PHONY: all_ubuntu
all_ubuntu: ubuntu64  ## Build all ubuntu images

.PHONY: ubuntu64
ubuntu64: ## Build ubuntu x86_64 images
ubuntu64: $(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-ubuntu-x86_64.tar.gz
ubuntu64: $(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-ubuntu-x86_64-build.tar.gz

.PHONY: alpine
alpine: ## Build alpine images
alpine: $(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-alpine.tar.gz
alpine: $(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-alpine-build.tar.gz

$(BUILD_CONTEXT)/crystal-amd64.tar.gz: $(TARBALLS)/crystal-$(CRYSTAL_VERSION)-1-linux-x86_64.tar.gz | $(BUILD_CONTEXT)
	cp $< $@

$(OUTPUT_DIR) $(BUILD_CONTEXT):
	mkdir -p $@

# Ubuntu x86_64
$(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-ubuntu-x86_64.tar.gz: ubuntu.Dockerfile $(BUILD_CONTEXT)/crystal-amd64.tar.gz $(OUTPUT_DIR)
	docker build --file ubuntu.Dockerfile -t $(DOCKER_TAG_UBUNTU) --target runtime $(BUILD_CONTEXT)
	docker save $(DOCKER_TAG_UBUNTU) | gzip > $@

$(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-ubuntu-x86_64-build.tar.gz: ubuntu.Dockerfile $(BUILD_CONTEXT)/crystal-amd64.tar.gz $(OUTPUT_DIR)
	docker build --file ubuntu.Dockerfile -t $(DOCKER_TAG_UBUNTU)-build --target build  $(BUILD_CONTEXT)
	docker save $(DOCKER_TAG_UBUNTU)-build | gzip > $@

# Alpine x86_64
$(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-alpine.tar.gz: alpine.Dockerfile $(BUILD_CONTEXT)/crystal-amd64.tar.gz $(OUTPUT_DIR)
	docker build --file alpine.Dockerfile -t $(DOCKER_TAG_ALPINE) --target runtime $(BUILD_CONTEXT)
	docker save $(DOCKER_TAG_ALPINE) | gzip > $@

$(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-alpine-build.tar.gz: alpine.Dockerfile $(BUILD_CONTEXT)/crystal-amd64.tar.gz $(OUTPUT_DIR)
	docker build --file alpine.Dockerfile -t $(DOCKER_TAG_ALPINE)-build --target build $(BUILD_CONTEXT)
	docker save $(DOCKER_TAG_ALPINE)-build | gzip > $@

alpine-84codes: ## Build and push docker build images based on the base images from 84codes
	docker buildx build --build-arg crystal_version=$(CRYSTAL_VERSION) -f alpine-84codes.Dockerfile --platform linux/amd64,linux/arm64 --tag crystallang/crystal:$(CRYSTAL_VERSION)-alpine-84codes-build --push .

ubuntu-84codes: ## Build and push docker build images based on the base images from 84codes
	docker buildx build --build-arg crystal_version=$(CRYSTAL_VERSION) -f ubuntu-84codes.Dockerfile --platform linux/amd64,linux/arm64 --tag crystallang/crystal:$(CRYSTAL_VERSION)-ubuntu-84codes-build --push .

.PHONY: clean
clean: ## Clean up build and output directories
	rm -Rf $(OUTPUT_DIR)
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
