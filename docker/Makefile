# Recipies for this Makefile

## Build all docker images
##   $ make DOCKER_REPOSITORY=crystal-lang/crystal DOCKER_TAG=nightly CRYSTAL_VERSION=0.xy.z CRYSTAL_DEB=... CRYSTAL_TARGZ=...
## Build ubuntu64 docker images
##   $ make ubuntu64 DOCKER_REPOSITORY=crystal-lang/crystal DOCKER_TAG=nightly CRYSTAL_VERSION=0.xy.z CRYSTAL_DEB=...
## Build alpine docker images
##   $ make alpine DOCKER_REPOSITORY=crystal-lang/crystal DOCKER_TAG=nightly CRYSTAL_VERSION=0.xy.z CRYSTAL_TARGZ=...

CRYSTAL_VERSION ?=   ## How the binaries should be branded
CRYSTAL_DEB ?=       ## Which crystal.deb file to install in debian based docker images (ubuntu)
CRYSTAL_TARGZ ?=     ## Which crystal.tar.gz file to install in docker images (alpine)
DOCKER_TAG ?=	     ## How to tag the docker image (examples: `0.27.2`, `nightly20190307`). `-build` will be appended for build images.
DOCKER_REPOSITORY ?= ## Docker hub repository to commit image

OUTPUT_DIR := build
BUILD_CONTEXT := $(CURDIR)/build-context
BUILD_ARGS_UBUNTU64 := -f ubuntu.Dockerfile --build-arg crystal_deb=crystal.deb $(BUILD_CONTEXT)/ubuntu64 --build-arg base_docker_image=ubuntu:bionic
BUILD_ARGS_UBUNTU32 := -f ubuntu.Dockerfile --build-arg crystal_deb=crystal.deb $(BUILD_CONTEXT)/ubuntu32 --build-arg base_docker_image=i386/ubuntu:bionic
BUILD_ARGS_ALPINE := -f alpine.Dockerfile --build-arg crystal_targz=crystal.tar.gz $(BUILD_CONTEXT)/alpine
DOCKER_TAG_UBUNTU := $(DOCKER_REPOSITORY):$(DOCKER_TAG)
DOCKER_TAG_ALPINE := $(DOCKER_REPOSITORY):$(DOCKER_TAG)-alpine

.PHONY: all64
all64: ubuntu64 alpine ## Build all x86_64 images

.PHONY: all32
all32: ubuntu32 ## Build all i386 images

.PHONY: all_ubuntu
all_ubuntu: ubuntu64 ubuntu32  ## Build all ubuntu images

.PHONY: ubuntu64
ubuntu64: ## Build ubuntu x86_64 images
ubuntu64: $(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-ubuntu-x86_64.tar.gz
ubuntu64: $(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-ubuntu-x86_64-build.tar.gz

.PHONY: ubuntu32
ubuntu32: ## Build ubuntu i386 images
ubuntu32: $(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-ubuntu-i386.tar.gz
ubuntu32: $(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-ubuntu-i386-build.tar.gz

.PHONY: alpine
alpine: ## Build alpine images
alpine: $(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-alpine.tar.gz
alpine: $(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-alpine-build.tar.gz

$(BUILD_CONTEXT)/ubuntu32: $(BUILD_CONTEXT)/ubuntu32/crystal.deb
$(BUILD_CONTEXT)/ubuntu64: $(BUILD_CONTEXT)/ubuntu64/crystal.deb

%/crystal.deb:
	mkdir -p $(shell dirname $@)
	cp $(CRYSTAL_DEB) $@

$(BUILD_CONTEXT)/alpine: $(BUILD_CONTEXT)/alpine/crystal.tar.gz

%/crystal.tar.gz:
	mkdir -p $(shell dirname $@)
	cp $(CRYSTAL_TARGZ) $@

$(OUTPUT_DIR):
	mkdir -p $(OUTPUT_DIR)

# Ubuntu x86_64
$(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-ubuntu-x86_64.tar.gz: $(BUILD_CONTEXT)/ubuntu64 $(OUTPUT_DIR)
	docker build -t $(DOCKER_TAG_UBUNTU) --target runtime $(BUILD_ARGS_UBUNTU64)
	docker save $(DOCKER_TAG_UBUNTU) | gzip > $(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-ubuntu.tar.gz

$(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-ubuntu-x86_64-build.tar.gz: $(BUILD_CONTEXT)/ubuntu64 $(OUTPUT_DIR)
	docker build -t $(DOCKER_TAG_UBUNTU)-build --target build  $(BUILD_ARGS_UBUNTU64)
	docker save $(DOCKER_TAG_UBUNTU)-build | gzip > $(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-ubuntu-build.tar.gz

# Ubuntu i386
$(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-ubuntu-i386.tar.gz: $(BUILD_CONTEXT)/ubuntu32 $(OUTPUT_DIR)
	docker build -t $(DOCKER_REPOSITORY):$(DOCKER_TAG)-i386 --target runtime $(BUILD_ARGS_UBUNTU32)
	docker save $(DOCKER_REPOSITORY):$(DOCKER_TAG)-i386 | gzip > $(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-i386.tar.gz

$(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-ubuntu-i386-build.tar.gz: $(BUILD_CONTEXT)/ubuntu32 $(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-ubuntu-i386.tar.gz
	docker build -t $(DOCKER_REPOSITORY):$(DOCKER_TAG)-i386-build --target build  $(BUILD_ARGS_UBUNTU32)
	docker save $(DOCKER_REPOSITORY):$(DOCKER_TAG)-i386-build | gzip > $(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-i386-build.tar.gz

# Alpine x86_64
$(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-alpine.tar.gz: $(BUILD_CONTEXT)/alpine $(OUTPUT_DIR)
	docker build -t $(DOCKER_TAG_ALPINE) --target runtime $(BUILD_ARGS_ALPINE)
	docker save $(DOCKER_TAG_ALPINE) | gzip > $(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-alpine.tar.gz

$(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-alpine-build.tar.gz: $(BUILD_CONTEXT)/alpine $(OUTPUT_DIR)
	docker build -t $(DOCKER_TAG_ALPINE)-build --target build $(BUILD_ARGS_ALPINE)
	docker save $(DOCKER_TAG_ALPINE)-build | gzip > $(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-alpine-build.tar.gz

.PHONY: clean
clean: ## Clean up build and output directories
	rm -Rf $(OUTPUT_DIR)
	rm -Rf $(CURDIR)/build-context

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
