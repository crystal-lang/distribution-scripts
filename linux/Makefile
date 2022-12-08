# Recipes for this Makefile

## Build everything
##   $ make CRYSTAL_VERSION=0.xx.y PREVIOUS_CRYSTAL_VERSION=...
## Build just amd64 distribution packages
##   $ make all_amd64 CRYSTAL_VERSION=0.xx.y PREVIOUS_CRYSTAL_VERSION=...
## Build everything for final release
##   $ make clean all no_cache=true pull_images=true release=true CRYSTAL_VERSION=0.xx.y PREVIOUS_CRYSTAL_VERSION=...

no_cache ?=    ## Disable the docker build cache
pull_images ?= ## Always pull docker images to ensure they're up to date
release ?=     ## Create an optimized build for the final release

CRYSTAL_VERSION ?=                 ## How the binaries should be branded
CRYSTAL_SHA1 ?= $(CRYSTAL_VERSION) ## Git tag/branch/sha1 to checkout and build source
PACKAGE_ITERATION ?= 1
PACKAGE_MAINTAINER = Crystal Team <crystal@manas.tech>

PREVIOUS_CRYSTAL_VERSION ?=             ## Version of the bootstrap compiler
PREVIOUS_CRYSTAL_PACKAGE_ITERATION ?= 1 ## Package iteration of the bootstrap compiler

SHARDS_VERSION = v0.17.1
GC_VERSION = v8.2.2
LIBPCRE_VERSION = 8.45
LIBEVENT_VERSION = release-2.1.12-stable

OUTPUT_DIR = build

COMPILER_OUTPUT_BASENAME = crystal-$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION)
OUTPUT_BASENAME_LINUX_AMD64 = $(OUTPUT_DIR)/$(COMPILER_OUTPUT_BASENAME)-linux-x86_64
OUTPUT_BASENAME_LINUX_AARCH64 = $(OUTPUT_DIR)/$(COMPILER_OUTPUT_BASENAME)-linux-aarch64

OUTPUT_BASENAME_LINUX_AMD64_BUNDLED = $(OUTPUT_BASENAME_LINUX_AMD64)-bundled
OUTPUT_BASENAME_LINUX_AARCH64_BUNDLED = $(OUTPUT_BASENAME_LINUX_AARCH64)-bundled

PREVIOUS_CRYSTAL_RELEASE_LINUX_AMD64_TARGZ ?= crystal-$(PREVIOUS_CRYSTAL_VERSION)-$(PREVIOUS_CRYSTAL_PACKAGE_ITERATION)-linux-x86_64.tar.gz ## Path to the x86_64 bootstrap compiler
PREVIOUS_CRYSTAL_RELEASE_LINUX_AARCH64_TARGZ ?= crystal-$(PREVIOUS_CRYSTAL_VERSION)-$(PREVIOUS_CRYSTAL_PACKAGE_ITERATION)-linux-aarch64.tar.gz ## Path to the aarch64 bootstrap compiler

PREVIOUS_CRYSTAL_RELEASE_LINUX_AMD64_TARGZ_URL ?= https://github.com/crystal-lang/crystal/releases/download/$(PREVIOUS_CRYSTAL_VERSION)/crystal-$(PREVIOUS_CRYSTAL_VERSION)-$(PREVIOUS_CRYSTAL_PACKAGE_ITERATION)-linux-x86_64.tar.gz ## URL to crystal-{version}-{package}-linux-x86_64.tar.gz
PREVIOUS_CRYSTAL_RELEASE_LINUX_AARCH64_TARGZ_URL ?= https://github.com/crystal-lang/crystal/releases/download/$(PREVIOUS_CRYSTAL_VERSION)/crystal-$(PREVIOUS_CRYSTAL_VERSION)-$(PREVIOUS_CRYSTAL_PACKAGE_ITERATION)-linux-aarch64.tar.gz ## URL to crystal-{version}-{package}-linux-x86_64.tar.gz

DOCKER_BUILD_ARGS = $(if $(no_cache),--no-cache )$(if $(pull_images),--pull )

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

BUILD_ARGS_AMD64 = $(BUILD_ARGS_COMMON) \
               --build-arg previous_crystal_release=$(PREVIOUS_CRYSTAL_RELEASE_LINUX_AMD64_TARGZ) \
               --build-arg musl_target=x86_64-linux-musl \
               --build-arg gnu_target=x86_64-unknown-linux-gnu

BUILD_ARGS_AARCH64 = $(BUILD_ARGS_COMMON) \
               --build-arg previous_crystal_release=$(PREVIOUS_CRYSTAL_RELEASE_LINUX_AARCH64_TARGZ) \
               --build-arg musl_target=aarch64-linux-musl \
               --build-arg gnu_target=aarch64-unknown-linux-gnu

BUILD_ARGS_AMD64_BUNDLED = $(BUILD_ARGS_AMD64) \
               $(BUILD_ARGS_LIB_VERSIONS)

BUILD_ARGS_AARCH64_BUNDLED = $(BUILD_ARGS_AARCH64) \
              $(BUILD_ARGS_LIB_VERSIONS)

.PHONY: all
all: all_amd64 all_aarch64 ## Build all distribution tarballs [default]

.PHONY: all_amd64
all_amd64: compress_amd64 clean_tmp ## Build distribution tarballs for amd64

.PHONY: all_aarch64
all_amd64: compress_aarch64 clean_tmp ## Build distribution tarballs for aarch64

.PHONY: build
build: build_amd64 build_aarch64 ## Build the raw uncompressed tarballs for all distributions

.PHONY: build_amd64
build_amd64: $(OUTPUT_BASENAME_LINUX_AMD64).tar ## Build the raw uncompressed tarball for amd64

.PHONY: build_aarch64
build_aarch64: $(OUTPUT_BASENAME_LINUX_AARCH64).tar ## Build the raw uncompressed tarball for aarch64

# Build an image, then copy an artefact to a path on the host
#
# Arguments:
# - $1: Platform (amd64 or aarch64)
# - $2: Build arguments
# - $3: Path of the artefact to copy
# - $4: Path to copy the artefact to
define build_in_container
docker buildx build --platform $(1) $(2) -t crystal-build-temp .
container_id="$$(docker create --platform $(1) crystal-build-temp)" \
  && docker cp "$$container_id":$(3) $(4) \
  && docker rm -v "$$container_id"
endef

# Bundle the compiler with libraries
#
# Arguments:
# - $1: Bundle name
# - $2: Compiler output
# - $3: Libraries output
define bundle
rm -rf $(1)
mkdir -p $(1)
tar -C $(1) -xf $(1).tar
tar -C $(1) -xf $(2)-libs.tar
endef

# Build the compiler

$(OUTPUT_BASENAME_LINUX_AARCH64).tar: Dockerfile $(OUTPUT_DIR)
	$(call build_in_container,linux/aarch64,$(BUILD_ARGS_AARCH64),/output/$(COMPILER_OUTPUT_BASENAME).tar,$@)

$(OUTPUT_BASENAME_LINUX_AMD64).tar: Dockerfile $(OUTPUT_DIR)
	$(call build_in_container,linux/amd64,$(BUILD_ARGS_AMD64),/output/$(COMPILER_OUTPUT_BASENAME).tar,$@)

# Build the bundled libraries

$(OUTPUT_BASENAME_LINUX_AMD64_BUNDLED)-libs.tar: bundled.dockerfile $(OUTPUT_DIR)
	$(call build_in_container,linux/amd64,$(BUILD_ARGS_AMD64_BUNDLED),/output/bundled-libs.tar,$@)

$(OUTPUT_BASENAME_LINUX_AARCH64_BUNDLED)-libs.tar: bundled.dockerfile $(OUTPUT_DIR)
	$(call build_in_container,linux/aarch64,$(BUILD_ARGS_AARCH64_BUNDLED),/output/bundled-libs.tar,$@)

# Create bundled archives

$(OUTPUT_BASENAME_LINUX_AMD64_BUNDLED).tar: $(OUTPUT_BASENAME_LINUX_AMD64_BUNDLED)
	tar -C $(OUTPUT_BASENAME_LINUX_AMD64_BUNDLED) -cf $@ ./

$(OUTPUT_BASENAME_LINUX_AARCH64_BUNDLED).tar: $(OUTPUT_BASENAME_LINUX_AARCH64_BUNDLED)
	tar -C $(OUTPUT_BASENAME_LINUX_AARCH64_BUNDLED) -cf $@ ./

$(OUTPUT_BASENAME_LINUX_AMD64_BUNDLED): $(OUTPUT_BASENAME_LINUX_AMD64).tar $(OUTPUT_BASENAME_LINUX_AMD64_BUNDLED)-libs.tar
	$(call bundle,$@,$(OUTPUT_BASENAME_LINUX_AMD64),$(OUTPUT_BASENAME_LINUX_AMD64_BUNDLED))

$(OUTPUT_BASENAME_LINUX_AARCH64_BUNDLED): $(OUTPUT_BASENAME_LINUX_AARCH64).tar $(OUTPUT_BASENAME_LINUX_AARCH64_BUNDLED)-libs.tar
	$(call bundle,$@,$(OUTPUT_BASENAME_LINUX_AARCH64),$(OUTPUT_BASENAME_LINUX_AARCH64_BUNDLED))

.PHONY: compress_amd64
compress_amd64: $(OUTPUT_BASENAME_LINUX_AMD64).tar.gz $(OUTPUT_BASENAME_LINUX_AMD64).tar.xz $(OUTPUT_BASENAME_LINUX_AMD64_BUNDLED).tar.gz

.PHONY: compress_aarch64
compress_aarch64: $(OUTPUT_BASENAME_LINUX_AARCH64).tar.gz $(OUTPUT_BASENAME_LINUX_AARCH64).tar.xz $(OUTPUT_BASENAME_LINUX_AARCH64_BUNDLED).tar.gz

$(PREVIOUS_CRYSTAL_RELEASE_LINUX_AARCH64_TARGZ): $(OUTPUT_DIR)
	wget  --protocol=https -O $(PREVIOUS_CRYSTAL_RELEASE_LINUX_AARCH64_TARGZ) $(PREVIOUS_CRYSTAL_RELEASE_LINUX_AARCH64_TARGZ_URL)

$(PREVIOUS_CRYSTAL_RELEASE_LINUX_AMD64_TARGZ): $(OUTPUT_DIR)
	wget  --protocol=https -O $(PREVIOUS_CRYSTAL_RELEASE_LINUX_AMD64_TARGZ) $(PREVIOUS_CRYSTAL_RELEASE_LINUX_AMD64_TARGZ_URL)

$(OUTPUT_DIR):
	mkdir -p $(OUTPUT_DIR)

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
