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

CRYSTAL_REPO ?= https://github.com/crystal-lang/crystal ## Allow to override the official repo with fork or local
CRYSTAL_VERSION ?=                 ## How the binaries should be branded
CRYSTAL_SHA1 ?= $(CRYSTAL_VERSION) ## Git tag/branch/sha1 to checkout and build source
PACKAGE_ITERATION ?= 1
PACKAGE_MAINTAINER = Crystal Team <crystal@manas.tech>

PREVIOUS_CRYSTAL_VERSION ?= ## Version of the bootstrap compiler
PREVIOUS_CRYSTAL_PACKAGE_ITERATION ?= 1## Package iteration of the bootstrap compiler
PREVIOUS_CRYSTAL_RELEASE_LINUX64_TARGZ ?= https://github.com/crystal-lang/crystal/releases/download/$(PREVIOUS_CRYSTAL_VERSION)/crystal-$(PREVIOUS_CRYSTAL_VERSION)-$(PREVIOUS_CRYSTAL_PACKAGE_ITERATION)-linux-x86_64.tar.gz ## url to crystal-{version}-{package}-linux-x86_64.tar.gz

SHARDS_VERSION = v0.18.0
GC_VERSION = v8.2.6
LIBPCRE2_VERSION = 10.44
LIBEVENT_VERSION = release-2.1.12-stable

OUTPUT_DIR = build
OUTPUT_BASENAME64 = $(OUTPUT_DIR)/crystal-$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION)-linux-x86_64

DOCKER_BUILD_ARGS = $(if $(no_cache),--no-cache )$(if $(pull_images),--pull )

BUILD_ARGS_COMMON = $(DOCKER_BUILD_ARGS) \
                    $(if $(release),--build-arg release=true) \
                    --build-arg crystal_repo=$(CRYSTAL_REPO) \
                    --build-arg crystal_version=$(CRYSTAL_VERSION) \
                    --build-arg crystal_sha1=$(CRYSTAL_SHA1) \
                    --build-arg shards_version=$(SHARDS_VERSION) \
                    --build-arg gc_version=$(GC_VERSION) \
                    --build-arg package_iteration=$(PACKAGE_ITERATION)

BUILD_ARGS64 = $(BUILD_ARGS_COMMON) \
               --build-arg previous_crystal_release=$(PREVIOUS_CRYSTAL_RELEASE_LINUX64_TARGZ)	\
               --build-arg musl_target=x86_64-linux-musl \
               --build-arg gnu_target=x86_64-unknown-linux-gnu

BUILD_ARGS64_BUNDLED = $(BUILD_ARGS64) \
               --build-arg libpcre2_version=$(LIBPCRE2_VERSION) \
               --build-arg libevent_version=$(LIBEVENT_VERSION)

.PHONY: all
all: all64 ## Build all distribution tarballs [default]

.PHONY: all64
all64: compress64 clean_tmp ## Build distribution tarballs for 64 bits

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

$(OUTPUT_BASENAME64).tar: Dockerfile
	mkdir -p $(OUTPUT_DIR)
	docker build $(BUILD_ARGS64) -t crystal-build-temp .
	container_id="$$(docker create crystal-build-temp)" \
	  && docker cp "$$container_id":/output/crystal-$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION).tar $@ \
	  && docker rm -v "$$container_id"

$(OUTPUT_BASENAME64)-bundled.tar: $(OUTPUT_BASENAME64)-bundled
	tar -C $(OUTPUT_BASENAME64)-bundled -cf $@ ./

$(OUTPUT_BASENAME64)-bundled: $(OUTPUT_BASENAME64).tar $(OUTPUT_DIR)/bundled-libs.tar
	rm -rf $@
	mkdir -p $@
	tar -C $@ -xf $(OUTPUT_BASENAME64).tar
	tar -C $@ -xf $(OUTPUT_DIR)/bundled-libs.tar

$(OUTPUT_DIR)/bundled-libs.tar: bundled.dockerfile
	mkdir -p $(OUTPUT_DIR)
	docker build $(BUILD_ARGS64_BUNDLED) -t crystal-build-temp -f bundled.dockerfile .
	container_id="$$(docker create crystal-build-temp)" \
	  && docker cp "$$container_id":/output/bundled-libs.tar $@ \
	  && docker rm -v "$$container_id"

.PHONY: compress64
compress64: $(OUTPUT_BASENAME64).tar.gz $(OUTPUT_BASENAME64).tar.xz $(OUTPUT_BASENAME64)-bundled.tar.gz ## Build compressed tarballs

$(OUTPUT_DIR)/%.gz: $(OUTPUT_DIR)/%
	gzip -c $< > $@

$(OUTPUT_DIR)/%.xz: $(OUTPUT_DIR)/%
	xz -T 0 -c $< > $@

.PHONY: clean
clean: ## Clean up build directory
	rm -Rf $(OUTPUT_DIR)

.PHONY: clean_tmp
clean_tmp: ## Clean up temporary build artifacts
	rm -Rf $(OUTPUT_DIR)/bundled-libs.tar
	rm -Rf $(OUTPUT_BASENAME64)-bundled
