# Recipies for this Makefile

## Build all docker images
##   $ make DOCKER_TAG=nightly CRYSTAL_VERSION=0.xy.z CRYSTAL_TARGZ=...
## Build ubuntu64 docker images
##   $ make ubuntu64 DOCKER_TAG=nightly CRYSTAL_VERSION=0.xy.z CRYSTAL_TARGZ=...
## Build alpine docker images
##   $ make alpine DOCKER_TAG=nightly CRYSTAL_VERSION=0.xy.z CRYSTAL_TARGZ=...

CRYSTAL_VERSION ?=   ## How the binaries should be branded
TARBALLS ?=          ## Folder which contains the Crystal tarballs to install in docker images.

DOCKER_TAG ?= $(CRYSTAL_VERSION)## How to tag the docker image (examples: `0.27.2`, `nightly20190307`). `-build` will be appended for build images.
DOCKER_REPOSITORY ?= crystallang/crystal## Docker hub repository to commit image (default: `crystallang/crystal`)

O := build
PLATFORM := linux/amd64,linux/arm64
BUILD_CONTEXT := build-context

.PHONY: all
all: ubuntu alpine ## Build all images

.PHONY: ubuntu
ubuntu: ## Build ubuntu images
ubuntu: $(O)/crystal-$(CRYSTAL_VERSION)-ubuntu-runtime-amd64.tar.gz
ubuntu: $(O)/crystal-$(CRYSTAL_VERSION)-ubuntu-build-amd64.tar.gz
ubuntu: $(O)/crystal-$(CRYSTAL_VERSION)-ubuntu-runtime-arm64.tar.gz
ubuntu: $(O)/crystal-$(CRYSTAL_VERSION)-ubuntu-build-arm64.tar.gz

.PHONY: alpine
alpine: ## Build alpine images
alpine: $(O)/crystal-$(CRYSTAL_VERSION)-alpine-runtime-amd64.tar.gz
alpine: $(O)/crystal-$(CRYSTAL_VERSION)-alpine-build-amd64.tar.gz
alpine: $(O)/crystal-$(CRYSTAL_VERSION)-alpine-runtime-arm64.tar.gz
alpine: $(O)/crystal-$(CRYSTAL_VERSION)-alpine-build-arm64.tar.gz

.SECONDEXPANSION:
$(O)/crystal-$(CRYSTAL_VERSION)-%.tar: $(BUILD_CONTEXT)/crystal-$(CRYSTAL_VERSION)-1-linux-$$(word 3,$$(subst -, ,$$*)).tar.gz | $(O)
	$(eval parts := $(subst -, ,$*))
	$(eval base := $(word 1,$(parts)))
	$(eval target := $(word 2,$(parts)))
	$(eval arch := $(word 3,$(parts)))
	$(eval tag=$(DOCKER_REPOSITORY):$(DOCKER_TAG)-$(base)-$(target))

	docker buildx build \
		--file $(base).Dockerfile\
		--build-arg crystal_version=$(CRYSTAL_VERSION)\
		--platform=linux/$(arch)\
		--target=$(target) \
		--tag=$(tag) \
		--output type=tar,dest=$@ \
		$(BUILD_CONTEXT)

$(O)/crystal-%.tar.gz: $(O)/crystal-%.tar
	gzip --keep $<

$(O) $(BUILD_CONTEXT):
	mkdir -p $@

$(BUILD_CONTEXT)/crystal-$(CRYSTAL_VERSION)-1-linux-amd64.tar.gz: $(TARBALLS)/crystal-$(CRYSTAL_VERSION)-1-linux-x86_64.tar.gz
$(BUILD_CONTEXT)/crystal-$(CRYSTAL_VERSION)-1-linux-arm64.tar.gz: $(TARBALLS)/crystal-$(CRYSTAL_VERSION)-1-linux-aarch64.tar.gz
$(BUILD_CONTEXT)/crystal-$(CRYSTAL_VERSION)-1-%.tar.gz: | $(BUILD_CONTEXT)
	cp $< $@

alpine-84codes: ## Build and push docker build images based on the base images from 84codes
	docker buildx build --build-arg crystal_version=$(CRYSTAL_VERSION) -f alpine-84codes.Dockerfile --platform linux/amd64,linux/arm64 --tag crystallang/crystal:$(CRYSTAL_VERSION)-alpine-84codes-build --push .

ubuntu-84codes: ## Build and push docker build images based on the base images from 84codes
	docker buildx build --build-arg crystal_version=$(CRYSTAL_VERSION) -f ubuntu-84codes.Dockerfile --platform linux/amd64,linux/arm64 --tag crystallang/crystal:$(CRYSTAL_VERSION)-ubuntu-84codes-build --push .

.PHONY: clean
clean: ## Clean up build and output directories
	rm -Rf $(O)
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
