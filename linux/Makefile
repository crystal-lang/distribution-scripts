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
CRYSTAL_REF ?= $(CRYSTAL_VERSION) ## Git tag/branch/sha1 to checkout and build source
PACKAGE_ITERATION ?= 1

PREVIOUS_CRYSTAL_VERSION ?= 1.10.1## Version of the bootstrap compiler
PREVIOUS_CRYSTAL_PACKAGE_ITERATION ?= 1## Package iteration of the bootstrap compiler
PREVIOUS_CRYSTAL_RELEASE_LINUX64_TARGZ ?= https://github.com/crystal-lang/crystal/releases/download/$(PREVIOUS_CRYSTAL_VERSION)/crystal-$(PREVIOUS_CRYSTAL_VERSION)-$(PREVIOUS_CRYSTAL_PACKAGE_ITERATION)-linux-x86_64.tar.gz ## url to crystal-{version}-{package}-linux-x86_64.tar.gz

OUTPUT_DIR = output
OUTPUT_BASENAME64 = $(OUTPUT_DIR)/crystal-$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION)-linux-x86_64

DOCKER_BUILD_ARGS = $(if $(no_cache),--no-cache )$(if $(pull_images),--pull )
BUILD_ARGS = $(DOCKER_BUILD_ARGS) \
             $(if $(release),--build-arg release=true)

.PHONY: all
all: build

.PHONY: build
build: compress64 ## Build distribution tarballs for 64 bits

$(OUTPUT_BASENAME64).tar: Dockerfile
	mkdir -p $(dir $@)
	docker buildx build $(BUILD_ARGS) --build-arg previous_crystal_release=$(PREVIOUS_CRYSTAL_RELEASE_LINUX64_TARGZ) --build-arg crystal_ref=$(CRYSTAL_REF) --build-arg crystal_version=$(CRYSTAL_VERSION) -o type=tar,dest=$@ .

$(OUTPUT_BASENAME64)-bundled.tar: bundled.dockerfile $(OUTPUT_BASENAME64).tar.gz
	mkdir -p $(dir $@)
	docker buildx build $(BUILD_ARGS) --build-context crystal_base=$(OUTPUT_DIR) --build-arg crystal_version=$(CRYSTAL_VERSION) -f $< -o type=tar,dest=$@ .

.PHONY: compress64
compress64: $(OUTPUT_BASENAME64).tar.gz $(OUTPUT_BASENAME64).tar.xz $(OUTPUT_BASENAME64)-bundled.tar.gz ## Build compressed tarballs

$(OUTPUT_DIR)/%.gz: $(OUTPUT_DIR)/%
	gzip -c $< > $@

$(OUTPUT_DIR)/%.xz: $(OUTPUT_DIR)/%
	xz -T 0 -c $< > $@

.PHONY: clean
clean: ## Clean up build directory
	rm -Rf $(OUTPUT_DIR)

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
