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

PREVIOUS_CRYSTAL_RELEASE_LINUX64_TARGZ ?=  ## url to crystal-{version}-{package}-linux-x86_64.tar.gz
PREVIOUS_CRYSTAL_RELEASE_LINUX32_TARGZ ?=  ## url to crystal-{version}-{package}-linux-i686.tar.gz

SHARDS_VERSION = v0.15.0
GC_VERSION = v8.0.4
LIBATOMIC_OPS_VERSION = v7.6.10
LIBPCRE_VERSION = 8.45

OUTPUT_DIR = build
OUTPUT_BASENAME64 = $(OUTPUT_DIR)/crystal-$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION)-linux-x86_64
OUTPUT_BASENAME32 = $(OUTPUT_DIR)/crystal-$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION)-linux-i686
FILES = files/crystal-wrapper

DEB_NAME64 = crystal_$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION)_amd64.deb
RPM_NAME64 = crystal-$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION).x86_64.rpm

DEB_NAME32 = crystal_$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION)_i386.deb
RPM_NAME32 = crystal-$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION).i386.rpm

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
               --build-arg alpine_image=alpine:3.13 \
               --build-arg musl_target=x86_64-linux-musl \
               --build-arg gnu_target=x86_64-unknown-linux-gnu

BUILD_ARGS64_BUNDLED = $(BUILD_ARGS64) \
               --build-arg libpcre_version=$(LIBPCRE_VERSION)

BUILD_ARGS32 = $(BUILD_ARGS_COMMON) \
               --build-arg previous_crystal_release=$(PREVIOUS_CRYSTAL_RELEASE_LINUX32_TARGZ) \
               --build-arg debian_image=i386/debian:10 \
               --build-arg alpine_image=i386/alpine:3.13 \
               --build-arg musl_target=i686-linux-musl \
               --build-arg gnu_target=i686-unknown-linux-gnu

PACKAGE_BRANDING_ARGS = --maintainer \"$(PACKAGE_MAINTAINER)\" --url \"https://crystal-lang.org/\"

FPM_FLAGS = --name crystal \
            --version $(CRYSTAL_VERSION) \
            --iteration $(PACKAGE_ITERATION) \
            --vendor \"$(PACKAGE_MAINTAINER)\" \
            --license APACHE-2.0

.PHONY: all
all: all64 all32 ## Build compressed and distribution packages [default]

.PHONY: all64
all64: compress64 package64 ## Build compressed and distribution packages for 64 bits

.PHONY: all32
all32: compress32 package32 ## Build compressed and distribution packages for 32 bits

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

$(OUTPUT_BASENAME64)-bundled.tar: $(OUTPUT_BASENAME64).tar $(OUTPUT_DIR)/bundled-libs.tar
	cp $< $@
	tar -Af $@ $(OUTPUT_DIR)/bundled-libs.tar

$(OUTPUT_DIR)/bundled-libs.tar: bundled.dockerfile
	mkdir -p $(OUTPUT_DIR)
	docker build $(BUILD_ARGS64_BUNDLED) -t crystal-build-temp -f bundled.dockerfile .
	container_id="$$(docker create crystal-build-temp)" \
	  && docker cp "$$container_id":/output/bundled-libs.tar $@ \
	  && docker rm -v "$$container_id"

.PHONY: compress64
compress64: $(OUTPUT_BASENAME64).tar.gz $(OUTPUT_BASENAME64).tar.xz $(OUTPUT_BASENAME64)-bundled.tar.gz ## Build compressed tarballs

%.tar.gz: %.tar
	gzip -c $< > $@

%.tar.xz: %.tar
	xz -T 0 -c $< > $@

.PHONY: package64
package64: $(OUTPUT_DIR)/$(DEB_NAME64) $(OUTPUT_DIR)/$(RPM_NAME64) ## Build distribution packages from the tarballs

.PHONY: docker-fpm
docker-fpm: Dockerfile-fpm
	docker build $(DOCKER_BUILD_ARGS) -t crystal-fpm -f Dockerfile-fpm .

$(OUTPUT_DIR)/$(DEB_NAME64): docker-fpm $(OUTPUT_BASENAME64).tar
	docker run --rm -v $(CURDIR)/build:/build crystal-fpm /bin/sh -c "\
    mkdir -p /tmp/crystal \
    && tar -C /tmp/crystal -xf $(OUTPUT_BASENAME64).tar \
    && mv /tmp/crystal/crystal-$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION)/share/licenses/crystal/LICENSE /tmp/crystal/crystal-$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION)/share/doc/crystal/copyright \
    && rm -Rf /tmp/crystal/crystal-*/share/licenses \
    && fpm --input-type dir --output-type deb \
           --architecture x86_64 $(PACKAGE_BRANDING_ARGS) \
           --depends gcc --depends pkg-config --depends libpcre3-dev --depends libevent-dev \
           --deb-recommends git --deb-recommends libssl-dev --deb-recommends libz-dev \
           --deb-suggests libxml2-dev --deb-suggests libgmp-dev --deb-suggests libyaml-dev --deb-suggests libreadline-dev \
           --force --package $(OUTPUT_DIR)/$(DEB_NAME64) \
           --prefix /usr \
           --chdir /tmp/crystal/crystal-$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION) \
           $(FPM_FLAGS) bin lib share"

$(OUTPUT_DIR)/$(RPM_NAME64): docker-fpm $(OUTPUT_BASENAME64).tar
	docker run --rm -v $(CURDIR)/build:/build crystal-fpm /bin/sh -c "\
    mkdir -p /tmp/crystal \
    && tar -C /tmp/crystal -xf $(OUTPUT_BASENAME64).tar \
    && fpm --input-type dir --output-type rpm \
           --architecture x86_64 $(PACKAGE_BRANDING_ARGS) \
           --depends gcc --depends pkgconfig --depends pcre-devel --depends libevent-devel \
           --force --package $(OUTPUT_DIR)/$(RPM_NAME64) \
           --prefix /usr \
           --chdir /tmp/crystal/crystal-$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION) \
           $(FPM_FLAGS) bin lib share"

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

.PHONY: package32
package32: $(OUTPUT_DIR)/$(DEB_NAME32) $(OUTPUT_DIR)/$(RPM_NAME32) ## Build distribution packages from the tarballs

$(OUTPUT_DIR)/$(DEB_NAME32): docker-fpm $(OUTPUT_BASENAME32).tar
	docker run --rm -v $(CURDIR)/build:/build crystal-fpm /bin/sh -c "\
    mkdir -p /tmp/crystal \
    && tar -C /tmp/crystal -xf $(OUTPUT_BASENAME32).tar \
    && mv /tmp/crystal/crystal-$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION)/share/licenses/crystal/LICENSE /tmp/crystal/crystal-$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION)/share/doc/crystal/copyright \
    && rm -Rf /tmp/crystal/crystal-*/share/licenses \
    && fpm --input-type dir --output-type deb \
           --architecture i386 $(PACKAGE_BRANDING_ARGS) \
           --depends gcc --depends pkg-config --depends libpcre3-dev --depends libevent-dev \
           --deb-recommends git --deb-recommends libssl-dev --deb-recommends libz-dev \
           --deb-suggests libxml2-dev --deb-suggests libgmp-dev --deb-suggests libyaml-dev --deb-suggests libreadline-dev \
           --force --package $(OUTPUT_DIR)/$(DEB_NAME32) \
           --prefix /usr \
           --chdir /tmp/crystal/crystal-$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION) \
           $(FPM_FLAGS) bin lib share"

$(OUTPUT_DIR)/$(RPM_NAME32): docker-fpm $(OUTPUT_BASENAME32).tar
	docker run --rm -v $(CURDIR)/build:/build crystal-fpm /bin/sh -c "\
    mkdir -p /tmp/crystal \
    && tar -C /tmp/crystal -xf $(OUTPUT_BASENAME32).tar \
    && fpm --input-type dir --output-type rpm \
           --architecture i386 $(PACKAGE_BRANDING_ARGS) \
           --depends gcc --depends pkgconfig --depends pcre-devel --depends libevent-devel \
           --force --package $(OUTPUT_DIR)/$(RPM_NAME32) \
           --prefix /usr \
           --chdir /tmp/crystal/crystal-$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION) \
           $(FPM_FLAGS) bin lib share"

.PHONY: clean
clean: ## Clean up build directory
	rm -Rf $(OUTPUT_DIR)
