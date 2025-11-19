# Recipies for this Makefile

## Build all docker images
##   $ make DOCKER_TAG=nightly CRYSTAL_VERSION=0.xy.z CRYSTAL_TARGZ=...
## Build ubuntu64 docker images
##   $ make ubuntu64 DOCKER_TAG=nightly CRYSTAL_VERSION=0.xy.z CRYSTAL_TARGZ=...
## Build alpine docker images
##   $ make alpine DOCKER_TAG=nightly CRYSTAL_VERSION=0.xy.z CRYSTAL_TARGZ=...

CRYSTAL_VERSION ?=   ## How the binaries should be branded
TARBARLLS ?=     ## Folder which contains the Crystal tarballs to install in docker images.
PLATFORM ?= linux/amd64,linux/arm64## Which platforms to build for (default: `linux/amd64,linux/arm64`)

DOCKER_TAG ?= $(CRYSTAL_VERSION)## How to tag the docker image (examples: `0.27.2`, `nightly20190307`). `-build` will be appended for build images.
DOCKER_REPOSITORY ?= crystallang/crystal## Docker hub repository to commit image (default: `crystallang/crystal`)

OUTPUT_DIR := build
BUILD_CONTEXT := $(CURDIR)/build-context

.PHONY: all
all: ubuntu alpine ## Build all images

.PHONY: ubuntu
ubuntu: ## Build ubuntu images
ubuntu: $(OUTPUT_DIR)/crystal-$(CRYSTAL_VERSION)-ubuntu.tar.gz
ubuntu: $(OUTPUT_DIR)/crystal-$(CRYSTAL_VERSION)-ubuntu-build.tar.gz

.PHONY: alpine
alpine: ## Build alpine images
alpine: $(OUTPUT_DIR)/crystal-$(CRYSTAL_VERSION)-alpine.tar.gz
alpine: $(OUTPUT_DIR)/crystal-$(CRYSTAL_VERSION)-alpine-build.tar.gz

$(OUTPUT_DIR)/crystal-$(CRYSTAL_VERSION)-%.tar: %.Dockerfile build-context | $(OUTPUT_DIR)
	docker buildx build --build-arg crystal_version=$(CRYSTAL_VERSION) --platform=$(PLATFORM) \
		-f $< --target=runtime --tag=$(DOCKER_REPOSITORY):$(DOCKER_TAG)-$* \
		--output type=tar,dest=$@ \
		$(BUILD_CONTEXT)

$(OUTPUT_DIR)/crystal-$(CRYSTAL_VERSION)-%-build.tar: %.Dockerfile build-context | $(OUTPUT_DIR)
	docker buildx build --build-arg crystal_version=$(CRYSTAL_VERSION) --platform=$(PLATFORM) \
		-f $< --target=build --tag=$(DOCKER_REPOSITORY):$(DOCKER_TAG)-$*-build \
		--output type=tar,dest=$@ \
		$(BUILD_CONTEXT)

$(OUTPUT_DIR)/crystal-%.tar.gz: $(OUTPUT_DIR)/crystal-%.tar
	gzip --keep $<

$(OUTPUT_DIR) $(BUILD_CONTEXT):
	mkdir -p $@

comma:=,
BUILD_CONTEXT_TARBALLS := $(addprefix $(BUILD_CONTEXT)/crystal-$(CRYSTAL_VERSION)-1-,$(addsuffix .tar.gz,$(patsubst linux/%,%,$(subst $(comma), ,$(PLATFORMS)))))

.PHONY: build-context
build-context: $(BUILD_CONTEXT_TARBALLS)

$(BUILD_CONTEXT)/crystal-$(CRYSTAL_VERSION)-1-amd64.tar.gz: $(TARBALLS)/crystal-$(CRYSTAL_VERSION)-1-x86_64.tar.gz
$(BUILD_CONTEXT)/crystal-$(CRYSTAL_VERSION)-1-arm64.tar.gz: $(TARBALLS)/crystal-$(CRYSTAL_VERSION)-1-aarch64.tar.gz
$(BUILD_CONTEXT)/crystal-$(CRYSTAL_VERSION)-1-%.tar.gz: | $(BUILD_CONTEXT)
	cp $< $@

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
