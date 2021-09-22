# Recipes for this Makefile

## Build everything
##   $ make CRYSTAL_VERSION=0.xx.y PREVIOUS_CRYSTAL_RELEASE_LINUX64_TARGZ=...
## Build just 64bit distribution packages
##   $ make package64 CRYSTAL_VERSION=0.xx.y PREVIOUS_CRYSTAL_RELEASE_LINUX64_TARGZ=...
## Build everything for final release
##   $ make clean all no_cache=true pull_images=true release=true CRYSTAL_VERSION=0.xx.y PREVIOUS_CRYSTAL_RELEASE_LINUX64_TARGZ=...

no_cache ?=    ## Disable the docker build cache
pull_images ?= ## Always pull docker images to ensure they're up to date
release ?=     ## Create an optimized build for the final release

CRYSTAL_VERSION ?=                 ## How the binaries should be branded
CRYSTAL_SHA1 ?= $(CRYSTAL_VERSION) ## Git tag/branch/sha1 to checkout and build source
PACKAGE_ITERATION ?= 1
PACKAGE_MAINTAINER = Crystal Team <crystal@manas.tech>

PREVIOUS_CRYSTAL_VERSION ?= ## Version of the bootstrap compiler
PREVIOUS_CRYSTAL_PACKAGE_ITERATION ?= 1 ## Package iteration of the bootstrap compiler
PREVIOUS_CRYSTAL_RELEASE_LINUX64_TARGZ ?= https://github.com/crystal-lang/crystal/releases/download/$(PREVIOUS_CRYSTAL_VERSION)/crystal-$(PREVIOUS_CRYSTAL_VERSION)-$(PREVIOUS_CRYSTAL_PACKAGE_ITERATION)-linux-x86_64.tar.gz ## url to crystal-{version}-{package}-linux-x86_64.tar.gz
PREVIOUS_CRYSTAL_RELEASE_LINUX32_TARGZ ?= https://github.com/crystal-lang/crystal/releases/download/$(PREVIOUS_CRYSTAL_VERSION)/crystal-$(PREVIOUS_CRYSTAL_VERSION)-$(PREVIOUS_CRYSTAL_PACKAGE_ITERATION)-linux-i686.tar.gz ## url to crystal-{version}-{package}-linux-i686.tar.gz

SHARDS_VERSION = v0.15.0
GC_VERSION = v8.0.4
LIBATOMIC_OPS_VERSION = v7.6.10

OUTPUT_DIR = build
OUTPUT_BASENAME64 = $(OUTPUT_DIR)/crystal-$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION)-linux-x86_64
OUTPUT_BASENAME32 = $(OUTPUT_DIR)/crystal-$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION)-linux-i686
FILES = files/crystal-wrapper

DOCKER_BUILD_ARGS = $(if $(no_cache),--no-cache )$(if $(pull_images),--pull )

BUILD_ARGS_COMMON = $(DOCKER_BUILD_ARGS) \
                    $(if $(release),--build-arg release=true) \
                    --build-arg crystal_version=$(CRYSTAL_VERSION) \
                    --build-arg crystal_sha1=$(CRYSTAL_SHA1) \
                    --build-arg shards_version=$(SHARDS_VERSION) \
                    --build-arg gc_version=$(GC_VERSION) \
                    --build-arg libatomic_ops_version=$(LIBATOMIC_OPS_VERSION) \
                    --build-arg package_iteration=$(PACKAGE_ITERATION)

BUILD_ARGS64 = $(BUILD_ARGS_COMMON) \
               --build-arg previous_crystal_release=$(PREVIOUS_CRYSTAL_RELEASE_LINUX64_TARGZ)	\
               --build-arg debian_image=debian:10 \
               --build-arg alpine_image=alpine:3.12 \
               --build-arg musl_target=x86_64-linux-musl \
               --build-arg gnu_target=x86_64-unknown-linux-gnu

BUILD_ARGS32 = $(BUILD_ARGS_COMMON) \
               --build-arg previous_crystal_release=$(PREVIOUS_CRYSTAL_RELEASE_LINUX32_TARGZ) \
               --build-arg debian_image=i386/debian:10 \
               --build-arg alpine_image=i386/alpine:3.12 \
               --build-arg musl_target=i686-linux-musl \
               --build-arg gnu_target=i686-unknown-linux-gnu

.PHONY: all
all: all64 all32 ## Build all distribution tarballs [default]

.PHONY: all64
all64: compress64 ## Build distribution tarballs for 64 bits

.PHONY: all32
all32: compress32 ## Build distribution tarballs for 32 bits

.PHONY: help
help: ## Show this help
	@echo
	@printf '\033[34mtargets:\033[0m\n'
	@grep -hE '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) |\
		sort |\
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo
	@printf '\033[34moptional variables:\033[0m\n'
	@grep -hE '^[a-zA-Z0-9_-]+ \?=.*?## .*$$' $(MAKEFILE_LIST) |\
		sort |\
		awk 'BEGIN {FS = " \\?=.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo
	@printf '\033[34mrecipes:\033[0m\n'
	@grep -hE '^##.*$$' $(MAKEFILE_LIST) |\
awk 'BEGIN {FS = "## "}; /^## [a-zA-Z_-]/ {printf "  \033[36m%s\033[0m\n", $$2}; /^##  / {printf "  %s\n", $$2}'

.PHONY: build
build: $(OUTPUT_BASENAME64).tar ## Build the raw uncompressed tarball

$(OUTPUT_BASENAME64).tar: Dockerfile $(FILES)
	mkdir -p $(OUTPUT_DIR)
	docker build $(BUILD_ARGS64) -t crystal-build-temp .
	container_id="$$(docker create crystal-build-temp)" \
	  && docker cp "$$container_id":/output/crystal-$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION).tar $(OUTPUT_BASENAME64).tar \
	  && docker rm -v "$$container_id"

.PHONY: compress64
compress64: $(OUTPUT_BASENAME64).tar.gz $(OUTPUT_BASENAME64).tar.xz ## Build compressed tarballs

.PHONY: build32
build32: $(OUTPUT_BASENAME32).tar ## Build the raw uncompressed tarball

$(OUTPUT_BASENAME32).tar: Dockerfile $(FILES)
	mkdir -p $(OUTPUT_DIR)
	docker build $(BUILD_ARGS32) -t crystal-build32-temp .
	container_id="$$(docker create crystal-build32-temp)" \
	  && docker cp "$$container_id":/output/crystal-$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION).tar $(OUTPUT_BASENAME32).tar \
	  && docker rm -v "$$container_id"

.PHONY: compress32
compress32: $(OUTPUT_BASENAME32).tar.gz $(OUTPUT_BASENAME32).tar.xz ## Build compressed tarballs

$(OUTPUT_DIR)/%.gz: $(OUTPUT_DIR)/%
	gzip -c $< > $@

$(OUTPUT_DIR)/%.xz: $(OUTPUT_DIR)/%
	xz -T 0 -c $< > $@

.PHONY: clean
clean: ## Clean up build directory
	rm -Rf $(OUTPUT_DIR)
