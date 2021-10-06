# Recipies for this Makefile

## Build all docker images
##   $ make DOCKER_TAG=nightly CRYSTAL_VERSION=0.xy.z CRYSTAL_DEB=... CRYSTAL_TARGZ=...
## Build ubuntu64 docker images
##   $ make ubuntu64 DOCKER_TAG=nightly CRYSTAL_VERSION=0.xy.z CRYSTAL_TARGZ=...
## Build alpine docker images
##   $ make alpine DOCKER_TAG=nightly CRYSTAL_VERSION=0.xy.z CRYSTAL_TARGZ=...

CRYSTAL_VERSION ?=   ## How the binaries should be branded
CRYSTAL_DEB ?=       ## Which crystal.deb file to install in debian based docker images (ubuntu32)
CRYSTAL_TARGZ ?=     ## Which crystal.tar.gz file to install in docker images (ubuntu64, alpine)
DOCKER_TAG ?= $(CRYSTAL_VERSION) ## How to tag the docker image (examples: `0.27.2`, `nightly20190307`). `-build` will be appended for build images.
DOCKER_REPOSITORY ?= crystallang/crystal ## Docker hub repository to commit image

GC_VERSION = v8.0.4

OUTPUT_DIR := build
BUILD_CONTEXT := $(CURDIR)/build-context
BUILD_ARGS_UBUNTU64 := --build-arg crystal_targz=crystal.tar.gz $(BUILD_CONTEXT)/ubuntu64 --build-arg base_docker_image=ubuntu:focal
BUILD_ARGS_ALPINE := --build-arg crystal_targz=crystal.tar.gz $(BUILD_CONTEXT)/alpine --build-arg gc_version=$(GC_VERSION)
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

$(BUILD_CONTEXT)/ubuntu64: ubuntu.Dockerfile $(BUILD_CONTEXT)/ubuntu64/crystal.tar.gz
	cp ubuntu.Dockerfile $@/Dockerfile

$(BUILD_CONTEXT)/alpine: alpine.Dockerfile $(BUILD_CONTEXT)/alpine/crystal.tar.gz
	cp alpine.Dockerfile $@/Dockerfile
	mkdir $@/files/
	cp ../linux/files/feature-thread-stackbottom-upstream.patch $@/files/feature-thread-stackbottom-upstream.patch

%/crystal.deb:
	mkdir -p $(shell dirname $@)
	cp $(CRYSTAL_DEB) $@

%/crystal.tar.gz:
	mkdir -p $(shell dirname $@)
	cp $(CRYSTAL_TARGZ) $@

$(OUTPUT_DIR):
	mkdir -p $(OUTPUT_DIR)

# Ubuntu x86_64
$(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-ubuntu-x86_64.tar.gz: $(BUILD_CONTEXT)/ubuntu64 $(OUTPUT_DIR)
	docker build -t $(DOCKER_TAG_UBUNTU) --target runtime $(BUILD_ARGS_UBUNTU64)
	docker save $(DOCKER_TAG_UBUNTU) | gzip > $@

$(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-ubuntu-x86_64-build.tar.gz: $(BUILD_CONTEXT)/ubuntu64 $(OUTPUT_DIR)
	docker build -t $(DOCKER_TAG_UBUNTU)-build --target build  $(BUILD_ARGS_UBUNTU64)
	docker save $(DOCKER_TAG_UBUNTU)-build | gzip > $@

# Alpine x86_64
$(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-alpine.tar.gz: $(BUILD_CONTEXT)/alpine $(OUTPUT_DIR)
	docker build -t $(DOCKER_TAG_ALPINE) --target runtime $(BUILD_ARGS_ALPINE)
	docker save $(DOCKER_TAG_ALPINE) | gzip > $@

$(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-alpine-build.tar.gz: $(BUILD_CONTEXT)/alpine $(OUTPUT_DIR)
	docker build -t $(DOCKER_TAG_ALPINE)-build --target build $(BUILD_ARGS_ALPINE)
	docker save $(DOCKER_TAG_ALPINE)-build | gzip > $@

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
