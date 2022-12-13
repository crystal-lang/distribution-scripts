# Recipies for this Makefile

## Build all docker images for x86_64
##   $ make arch=x86_64 DOCKER_TAG=nightly CRYSTAL_VERSION=0.xy.z CRYSTAL_DEB=... CRYSTAL_TARGZ=...
## Build all docker images for aarch64
##   $ make arch=aarch64 DOCKER_TAG=nightly CRYSTAL_VERSION=0.xy.z CRYSTAL_DEB=... CRYSTAL_TARGZ=...
## Build ubuntu docker images for x86_64
##   $ make ubuntu arch=x86_64 DOCKER_TAG=nightly CRYSTAL_VERSION=0.xy.z CRYSTAL_TARGZ=...
## Build alpine docker images for aarch64
##   $ make alpine arch=aarch64 DOCKER_TAG=nightly CRYSTAL_VERSION=0.xy.z CRYSTAL_TARGZ=...

arch ?=        ## Architecture to build for (x86_64, aarch64)
no_cache ?=    ## Disable the docker build cache
pull_images ?= ## Always pull docker images to ensure they're up to date

CRYSTAL_VERSION ?=   ## How the binaries should be branded
PACKAGE_ITERATION ?= 1
PACKAGE_MAINTAINER = Crystal Team <crystal@manas.tech>

CRYSTAL_DEB ?=       ## Which crystal.deb file to install in debian based docker images (ubuntu32)
CRYSTAL_TARGZ ?=     ## Which crystal.tar.gz file to install in docker images (ubuntu, alpine)

DOCKER_TAG ?= $(CRYSTAL_VERSION)## How to tag the docker image (examples: `0.27.2`, `nightly20190307`). `-build` will be appended for build images.
DOCKER_REPOSITORY ?= crystallang/crystal## Docker hub repository to commit image

GC_VERSION = v8.2.2

ifeq ($(arch),x86_64)
  DOCKER_BUILD_PLATFORM = linux/amd64
else ifeq ($(arch),aarch64)
  DOCKER_BUILD_PLATFORM = linux/arm64
else
  $(error Expected arch to be one of 'x86_64', or 'aarch64', got: $(arch))
endif

BASE_UBUNTU_DOCKER_IMAGE = ubuntu:focal

OUTPUT_DIR := build

BUILD_CONTEXT := $(CURDIR)/build-context

BUILD_ARGS_COMMON := \
                      $(if $(pull_images),--pull) \
                      $(if $(no_cache),--no-cache) \
                      --platform $(DOCKER_BUILD_PLATFORM) \
                      --label "crystal_version=$(CRYSTAL_VERSION)" \
                      --label "package_iteration=$(PACKAGE_ITERATION)" \
                      --label "package_maintainer=$(PACKAGE_MAINTAINER)"

BUILD_ARGS_UBUNTU := $(BUILD_ARGS_COMMON) \
                      --build-arg crystal_targz=crystal.tar.gz \
                      --build-arg base_docker_image=$(BASE_UBUNTU_DOCKER_IMAGE) \
                      $(BUILD_CONTEXT)/ubuntu

BUILD_ARGS_ALPINE := $(BUILD_ARGS_COMMON) \
                     --build-arg crystal_targz=crystal.tar.gz \
                     --build-arg gc_version=$(GC_VERSION) \
                     $(BUILD_CONTEXT)/alpine

DOCKER_TAG_UBUNTU := $(DOCKER_REPOSITORY):$(DOCKER_TAG)
DOCKER_TAG_ALPINE := $(DOCKER_REPOSITORY):$(DOCKER_TAG)-alpine

.PHONY: all
all: ubuntu alpine ## Build all images

.PHONY: all_ubuntu
all_ubuntu: ubuntu  ## Build all ubuntu images

.PHONY: ubuntu
ubuntu: ## Build ubuntu images
ubuntu: $(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-ubuntu-$(arch).tar.gz
ubuntu: $(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-ubuntu-$(arch)-build.tar.gz

.PHONY: alpine
alpine: ## Build alpine images
alpine: $(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-alpine-$(arch).tar.gz
alpine: $(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-alpine-$(arch)-build.tar.gz

$(BUILD_CONTEXT)/ubuntu: ubuntu.Dockerfile $(BUILD_CONTEXT)/ubuntu/crystal.tar.gz
	cp ubuntu.Dockerfile $@/Dockerfile

$(BUILD_CONTEXT)/alpine: alpine.Dockerfile $(BUILD_CONTEXT)/alpine/crystal.tar.gz
	cp alpine.Dockerfile $@/Dockerfile
	mkdir $@/files/

%/crystal.deb:
	mkdir -p $(shell dirname $@)
	cp $(CRYSTAL_DEB) $@

%/crystal.tar.gz:
	mkdir -p $(shell dirname $@)
	cp $(CRYSTAL_TARGZ) $@

$(OUTPUT_DIR):
	mkdir -p $(@)

$(BUILD_CONTEXT):
	mkdir -p $(@)

.PHONY: scripts
scripts: $(BUILD_CONTEXT)
	cp -r ../scripts $(BUILD_CONTEXT)/alpine

# Ubuntu
$(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-ubuntu-$(arch).tar.gz: $(BUILD_CONTEXT)/ubuntu $(OUTPUT_DIR)
	docker buildx build --tag $(DOCKER_TAG_UBUNTU) --target runtime -o type=docker,dest=- $(BUILD_ARGS_UBUNTU) | gzip > $@

$(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-ubuntu-$(arch)-build.tar.gz: $(BUILD_CONTEXT)/ubuntu $(OUTPUT_DIR)
	docker buildx build --tag $(DOCKER_TAG_UBUNTU)-build --target build -o type=docker,dest=- $(BUILD_ARGS_UBUNTU) | gzip > $@

# Alpine
$(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-alpine-$(arch).tar.gz: $(BUILD_CONTEXT)/alpine $(OUTPUT_DIR) scripts
	docker buildx build --tag $(DOCKER_TAG_ALPINE) --target runtime -o type=docker,dest=- $(BUILD_ARGS_ALPINE) | gzip > $@

$(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-alpine-$(arch)-build.tar.gz: $(BUILD_CONTEXT)/alpine $(OUTPUT_DIR) scripts
	docker buildx build --tag $(DOCKER_TAG_ALPINE)-build --target build -o type=docker,dest=- $(BUILD_ARGS_ALPINE) | gzip > $@

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
