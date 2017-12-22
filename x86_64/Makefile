# Recipes for this Makefile

## Build everything
##   $ make
## Build just distribution packages
##   $ make package
## Build everything for final release
##   $ make clean all no_cache=true pull_images=true release=true

no_cache ?=    ## Disable the docker build cache
pull_images ?= ## Always pull docker images to ensure they're up to date
release ?=     ## Create an optimized build for the final release

CRYSTAL_VERSION = 0.24.1
PACKAGE_ITERATION = 1
SHARDS_VERSION = v0.7.2
PREVIOUS_CRYSTAL_RELEASE = https://github.com/crystal-lang/crystal/releases/download/0.23.1/crystal-0.23.1-3-linux-x86_64.tar.gz

GC_VERSION = v7.4.6
LIBATOMIC_OPS_VERSION = v7.4.8

LIBEVENT_VERSION = release-2.1.8-stable

OUTPUT_DIR = build
OUTPUT_BASENAME = $(OUTPUT_DIR)/crystal-$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION)-x86_64
FILES = files/crystal-wrapper

DEB_NAME = crystal_$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION)_amd64.deb
RPM_NAME = crystal-$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION).x86_64.rpm

DOCKER_BUILD_ARGS = $(if $(no_cache),--no-cache )$(if $(pull_images),--pull )
BUILD_ARGS = $(DOCKER_BUILD_ARGS)$(if $(release),--build-arg release=true )--build-arg crystal_version=$(CRYSTAL_VERSION) --build-arg shards_version=$(SHARDS_VERSION) --build-arg gc_version=$(GC_VERSION) --build-arg libatomic_ops_version=$(LIBATOMIC_OPS_VERSION) --build-arg libevent_version=$(LIBEVENT_VERSION) --build-arg previous_crystal_release=$(PREVIOUS_CRYSTAL_RELEASE)

.PHONY: all
all: compress package ## Build compressed omnibus and distribution packages [default]

.PHONY: help
help: ## Show this help
	@echo
	@printf '\033[34mtargets:\033[0m\n'
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) |\
		sort |\
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo
	@printf '\033[34moptional variables:\033[0m\n'
	@grep -hE '^[a-zA-Z_-]+ \?=.*?## .*$$' $(MAKEFILE_LIST) |\
		sort |\
		awk 'BEGIN {FS = " \\?=.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo
	@printf '\033[34mrecipes:\033[0m\n'
	@grep -hE '^##.*$$' $(MAKEFILE_LIST) |\
awk 'BEGIN {FS = "## "}; /^## [a-zA-Z_-]/ {printf "  \033[36m%s\033[0m\n", $$2}; /^##  / {printf "  %s\n", $$2}'

.PHONY: build
build: $(OUTPUT_BASENAME).tar ## Build the raw uncompressed omnibus tarball

$(OUTPUT_BASENAME).tar: Dockerfile $(FILES)
	mkdir -p $(OUTPUT_DIR)
	docker build $(BUILD_ARGS) -t crystal-build-temp .
	container_id="$$(docker create crystal-build-temp)" \
	  && docker cp "$$container_id":/output/crystal-$(CRYSTAL_VERSION).tar $(OUTPUT_BASENAME).tar \
	  && docker rm -v "$$container_id"

.PHONY: compress
compress: $(OUTPUT_BASENAME).tar.gz $(OUTPUT_BASENAME).tar.xz ## Build compressed omnibus tarballs

$(OUTPUT_BASENAME).tar.gz: $(OUTPUT_BASENAME).tar
	gzip -c $(OUTPUT_BASENAME).tar > $(OUTPUT_BASENAME).tar.gz

$(OUTPUT_BASENAME).tar.xz: $(OUTPUT_BASENAME).tar
	xz -T 0 -c $(OUTPUT_BASENAME).tar > $(OUTPUT_BASENAME).tar.xz

.PHONY: package
package: $(OUTPUT_DIR)/$(DEB_NAME) $(OUTPUT_DIR)/$(RPM_NAME) ## Build distribution packages from the omnibus tarballs

PHONY: docker-fpm
docker-fpm: Dockerfile-fpm
	docker build $(DOCKER_BUILD_ARGS) -t crystal-fpm -f Dockerfile-fpm .

$(OUTPUT_DIR)/$(DEB_NAME): docker-fpm $(OUTPUT_BASENAME).tar
	docker run --rm -v $(CURDIR)/build:/build crystal-fpm /bin/sh -c "\
    mkdir -p /tmp/crystal \
    && tar -C /tmp/crystal -xf $(OUTPUT_BASENAME).tar \
    && mv /tmp/crystal/crystal-$(CRYSTAL_VERSION)/share/licenses/crystal/LICENSE /tmp/crystal/crystal-$(CRYSTAL_VERSION)/share/doc/crystal/copyright \
    && rm -Rf /tmp/crystal/crystal-*/share/licenses \
    && fpm --input-type dir --output-type deb \
           --name crystal --version $(CRYSTAL_VERSION) --iteration $(PACKAGE_ITERATION) \
           --architecture x86_64 --maintainer \"Chris Hobbs <chris@rx14.co.uk>\" \
           --depends gcc --depends libpcre3-dev --depends libevent-dev \
           --deb-recommends git --deb-recommends libssl-dev \
           --deb-suggests libxml2-dev --deb-suggests libgmp-dev --deb-suggests libyaml-dev --deb-suggests libreadline-dev \
           --force --package $(OUTPUT_DIR)/$(DEB_NAME) \
           --prefix /usr --chdir /tmp/crystal/crystal-$(CRYSTAL_VERSION) bin lib share"

$(OUTPUT_DIR)/$(RPM_NAME): docker-fpm $(OUTPUT_BASENAME).tar
	docker run --rm -v $(CURDIR)/build:/build crystal-fpm /bin/sh -c "\
    mkdir -p /tmp/crystal \
    && tar -C /tmp/crystal -xf $(OUTPUT_BASENAME).tar \
    && fpm --input-type dir --output-type rpm \
           --name crystal --version $(CRYSTAL_VERSION) --iteration $(PACKAGE_ITERATION) \
           --architecture x86_64 --maintainer \"Chris Hobbs <chris@rx14.co.uk>\" \
           --depends gcc --depends pcre-devel --depends libevent-devel \
           --force --package $(OUTPUT_DIR)/$(RPM_NAME) \
           --prefix /usr --chdir /tmp/crystal/crystal-$(CRYSTAL_VERSION) bin lib share"

.PHONY: clean
clean: ## Clean up build directory
	rm -Rf $(OUTPUT_DIR)
