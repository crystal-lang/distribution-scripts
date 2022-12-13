# Recipes for this Makefile

## Build everything for x86_64
##   $ make arch=x86_64 CRYSTAL_VERSION=0.xx.y PREVIOUS_CRYSTAL_VERSION=...
## Build everything for aarch64
##   $ make arch=aarch64 CRYSTAL_VERSION=0.xx.y PREVIOUS_CRYSTAL_VERSION=...
## Build everything for final release
##   $ make clean all arch=<target-platform> no_cache=true pull_images=true release=true CRYSTAL_VERSION=0.xx.y PREVIOUS_CRYSTAL_VERSION=...

arch ?=        ## Architecture to build for (x86_64, aarch64)
no_cache ?=    ## Disable the docker build cache
pull_images ?= ## Always pull docker images to ensure they're up to date
release ?=     ## Create an optimized build for the final release
bootstrap_aarch64 ?= true## Extract the bootstrap compiler from and aarch64 image until tier-1 aarch64 artefact available

CRYSTAL_VERSION ?=                 ## How the binaries should be branded
CRYSTAL_SHA1 ?= $(CRYSTAL_VERSION) ## Git tag/branch/sha1 to checkout and build source
PACKAGE_ITERATION ?= 1
PACKAGE_MAINTAINER = Crystal Team <crystal@manas.tech>

PREVIOUS_CRYSTAL_VERSION ?=            ## Version of the bootstrap compiler
PREVIOUS_CRYSTAL_PACKAGE_ITERATION ?= 1## Package iteration of the bootstrap compiler

SHARDS_VERSION = v0.17.1
GC_VERSION = v8.2.2
LIBPCRE_VERSION = 8.45
LIBEVENT_VERSION = release-2.1.12-stable

OUTPUT_DIR = build

ifeq ($(arch),x86_64)
  DOCKER_BUILD_PLATFORM = linux/amd64
else ifeq ($(arch),aarch64)
  DOCKER_BUILD_PLATFORM = linux/arm64
else
  $(error Expected arch to be one of 'x86_64', or 'aarch64', got: $(arch))
endif

COMPILER_OUTPUT_BASENAME = crystal-$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION)

OUTPUT_BASENAME = $(OUTPUT_DIR)/$(COMPILER_OUTPUT_BASENAME)-linux-$(arch)
OUTPUT_BASENAME_BUNDLED = $(OUTPUT_BASENAME)-bundled

PREVIOUS_CRYSTAL_RELEASE_TARGZ ?= $(OUTPUT_DIR)/crystal-$(PREVIOUS_CRYSTAL_VERSION)-$(PREVIOUS_CRYSTAL_PACKAGE_ITERATION)-linux-$(arch).tar.gz## Path to the bootstrap compiler
PREVIOUS_CRYSTAL_RELEASE_TARGZ_URL ?= https://github.com/crystal-lang/crystal/releases/download/$(PREVIOUS_CRYSTAL_VERSION)/crystal-$(PREVIOUS_CRYSTAL_VERSION)-$(PREVIOUS_CRYSTAL_PACKAGE_ITERATION)-linux-$(arch).tar.gz## URL to crystal-{version}-{package}-linux-$(arch).tar.gz

BOOTSTRAP_AARCH64_IMAGE=84codes/crystal:$(PREVIOUS_CRYSTAL_VERSION)-alpine

DOCKER_PULL = $(if $(pull_images),--pull )
DOCKER_BUILD_ARGS = $(if $(no_cache),--no-cache )$(DOCKER_PULL)

BUILD_ARGS_LIB_VERSIONS = \
               --build-arg libpcre_version=$(LIBPCRE_VERSION) \
               --build-arg libevent_version=$(LIBEVENT_VERSION)

BUILD_ARGS_COMMON = $(DOCKER_BUILD_ARGS) \
                    $(if $(release),--build-arg release=true) \
                    --build-arg crystal_version=$(CRYSTAL_VERSION) \
                    --build-arg crystal_sha1=$(CRYSTAL_SHA1) \
                    --build-arg shards_version=$(SHARDS_VERSION) \
                    --build-arg gc_version=$(GC_VERSION) \
                    --build-arg package_iteration=$(PACKAGE_ITERATION)

BUILD_ARGS = $(BUILD_ARGS_COMMON) \
               --build-arg previous_crystal_release=$(PREVIOUS_CRYSTAL_RELEASE_TARGZ) \
               --build-arg musl_target=$(arch)-linux-musl \
               --build-arg gnu_target=$(arch)-unknown-linux-gnu

BUILD_ARGS_BUNDLED = $(BUILD_ARGS) \
		$(BUILD_ARGS_LIB_VERSIONS) \
		-f bundled.dockerfile

.PHONY: all
all: all_linux ## Build all distribution tarballs [default]

.PHONY: all_linux
all_linux: compress_linux clean_tmp ## Build distribution tarballs for linux binaries

.PHONY: build
build: $(OUTPUT_BASENAME).tar ## Build the raw uncompressed tarballs for all distributions

.PHONY: build_linux
build_linux: $(OUTPUT_BASENAME).tar ## Build the raw uncompressed tarball for linux

# Build the compiler

$(OUTPUT_BASENAME).tar: Dockerfile $(OUTPUT_DIR) $(PREVIOUS_CRYSTAL_RELEASE_TARGZ) scripts
	$(call build_in_container,$(DOCKER_BUILD_PLATFORM),$(BUILD_ARGS),/output/$(COMPILER_OUTPUT_BASENAME).tar,$@)

# Build the bundled libraries

$(OUTPUT_BASENAME_BUNDLED)-libs.tar: bundled.dockerfile $(OUTPUT_DIR) scripts
	$(call build_in_container,$(DOCKER_BUILD_PLATFORM),$(BUILD_ARGS_BUNDLED),/output/bundled-libs.tar,$@)

# Create bundled archives

$(OUTPUT_BASENAME_BUNDLED).tar: $(OUTPUT_BASENAME_BUNDLED)
	tar -C $(OUTPUT_BASENAME_BUNDLED) -cf $@ ./

$(OUTPUT_BASENAME_BUNDLED): $(OUTPUT_BASENAME).tar $(OUTPUT_BASENAME_BUNDLED)-libs.tar
	rm -rf $@
	mkdir -p $@
	tar -C $@ -xf $(OUTPUT_BASENAME).tar
	tar -C $@ -xf $(OUTPUT_BASENAME_BUNDLED)-libs.tar

.PHONY: compress_linux
compress_linux: $(OUTPUT_BASENAME).tar.gz $(OUTPUT_BASENAME).tar.xz $(OUTPUT_BASENAME_BUNDLED).tar.gz

$(PREVIOUS_CRYSTAL_RELEASE_TARGZ): $(OUTPUT_DIR)
	if [ "$(arch)" = "aarch64" ] && [ "$(bootstrap_aarch64)" = "true" ]; \
	then \
		container_id=$$(docker create $(DOCKER_PULL) --platform linux/arm64 "$(BOOTSTRAP_AARCH64_IMAGE)"); \
		workdir=$$(mktemp -d); \
		mkdir -p "$$workdir/usr/lib/crystal/bin"; \
		docker cp "$$container_id:/usr/bin/crystal" "$$workdir/usr/lib/crystal/bin" \
		&& docker cp "$$container_id:/usr/bin/shards" "$$workdir/usr/lib/crystal/bin" \
		&& tar -C "$$workdir" -czf "$@" usr/lib/crystal/bin/{crystal,shards} \
		&& rm -r "$$workdir"; \
	else \
		curl --location --proto '=https' --tlsv1.2 --show-error --silent --fail \
		-o "$(@)" "$(PREVIOUS_CRYSTAL_RELEASE_TARGZ_URL)"; \
	fi

$(OUTPUT_DIR):
	mkdir -p $(OUTPUT_DIR)

.PHONY: scripts
scripts: ## Copy helper scripts to output directory
	cp -r ../scripts $(OUTPUT_DIR)

$(OUTPUT_DIR)/%.gz: $(OUTPUT_DIR)/%
	gzip -c $< > $@

$(OUTPUT_DIR)/%.xz: $(OUTPUT_DIR)/%
	xz -T 0 -c $< > $@

.PHONY: clean
clean: ## Clean up build directory
	rm -Rf $(OUTPUT_DIR)

.PHONY: clean_tmp
clean_tmp: ## Clean up temporary build artifacts
	rm -Rf $(OUTPUT_DIR)/*-bundled-libs.tar
	rm -Rf $(OUTPUT_DIR)/*-bundled

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

# Build an image, then copy an artefact to a path on the host
#
# Arguments:
# - $1: Platform (amd64 or aarch64)
# - $2: Build arguments
# - $3: Path of the artefact to copy
# - $4: Path to copy the artefact to
define build_in_container
docker buildx build --platform $(1) $(2) -t crystal-build-temp . ; \
  container_id="$$(docker create --platform $(1) crystal-build-temp)" \
  && docker cp "$$container_id:$(3)" $(4) \
  && docker rm -v "$$container_id"
endef
