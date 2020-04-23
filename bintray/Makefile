-include Makefile.local # for local options BINTRAY_USERNAME, BINTRAY_API_KEY

CRYSTAL_VERSION   ?=         ## How the binaries should be branded
PACKAGE_ITERATION ?= 1
force ?=                     ## Force publish of existing file

PACKAGE_MAINTAINER = Crystal Team <crystal@manas.tech>

FPM_FLAGS = --name crystal \
            --version $(CRYSTAL_VERSION) \
            --iteration $(PACKAGE_ITERATION) \
            --vendor \"$(PACKAGE_MAINTAINER)\" \
            --maintainer \"$(PACKAGE_MAINTAINER)\" \
            --url \"https://crystal-lang.org/\" \
            --description \"Crystal programming language compiler\" \
            --license APACHE-2.0 \
            --provides crystal --provides shards

CRYSTAL_LINUX64_TARGZ   ?= ## url or path to crystal-{version}-{package}-linux-x86_64.tar.gz
CRYSTAL_LINUX32_TARGZ   ?= ## url or path to crystal-{version}-{package}-linux-i686.tar.gz

OUTPUT_DIR = build
OUTPUT_BASENAME64 = $(OUTPUT_DIR)/crystal-$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION)-linux-x86_64
OUTPUT_BASENAME32 = $(OUTPUT_DIR)/crystal-$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION)-linux-i686

SHELL := /bin/bash

LOCAL_CRYSTAL_LINUX64_TARGZ = $(OUTPUT_DIR)/crystal-linux64.tar.gz
LOCAL_CRYSTAL_LINUX32_TARGZ = $(OUTPUT_DIR)/crystal-linux32.tar.gz

define prepare_binary
	mkdir -p $(OUTPUT_DIR)
	if [[ "$(1)" =~ ^http(s?):\/\/ ]]; \
	then curl -L -o $(2) "$(1)"; \
	else cp "$(1)" $(2); \
	fi
endef

$(LOCAL_CRYSTAL_LINUX64_TARGZ):
	$(call prepare_binary,$(CRYSTAL_LINUX64_TARGZ),$(LOCAL_CRYSTAL_LINUX64_TARGZ))

$(LOCAL_CRYSTAL_LINUX32_TARGZ):
	$(call prepare_binary,$(CRYSTAL_LINUX32_TARGZ),$(LOCAL_CRYSTAL_LINUX32_TARGZ))

clean:
	rm -Rf $(OUTPUT_DIR)

.PHONY: docker-fpm
docker-fpm: Dockerfile-fpm
	docker build $(DOCKER_BUILD_ARGS) -t crystal-fpm -f Dockerfile-fpm .

DEB_NAME64 = crystal_$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION)_amd64.deb
DEB_NAME32 = crystal_$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION)_i386.deb
DEB_DISTROS = jessie,stretch,buster,trusty,xenial,bionic,eoan
PUBLISH_FLAGS = publish=1$(if $(force),;override=1)

.PHONY: all
all: deb

.PHONY: deb
deb: $(OUTPUT_DIR)/$(DEB_NAME64) $(OUTPUT_DIR)/$(DEB_NAME32)

.PHONY: publish
publish:
	curl -T $(OUTPUT_DIR)/$(DEB_NAME64) -u$(BINTRAY_USERNAME):$(BINTRAY_API_KEY) "https://api.bintray.com/content/crystal/apt/crystal/$(CRYSTAL_VERSION)/$(DEB_NAME64);deb_distribution=$(DEB_DISTROS);deb_component=main;deb_architecture=amd64;$(PUBLISH_FLAGS)"
	curl -T $(OUTPUT_DIR)/$(DEB_NAME32) -u$(BINTRAY_USERNAME):$(BINTRAY_API_KEY) "https://api.bintray.com/content/crystal/apt/crystal/$(CRYSTAL_VERSION)/$(DEB_NAME32);deb_distribution=$(DEB_DISTROS);deb_component=main;deb_architecture=i386;$(PUBLISH_FLAGS)"

# $ make set_version_date CRYSTAL_VERSION=0.33.0 CRYSTAL_VERSION_DATE=2020-02-14
.PHONY: set_version_date
set_version_date:
	curl -v --data '{"released": "$(CRYSTAL_VERSION_DATE)T12:00:00.000Z"}' -H "Content-Type: application/json" -X PATCH -u$(BINTRAY_USERNAME):$(BINTRAY_API_KEY) "https://api.bintray.com/packages/crystal/apt/crystal/versions/$(CRYSTAL_VERSION)"

$(OUTPUT_DIR)/$(DEB_NAME64): docker-fpm $(LOCAL_CRYSTAL_LINUX64_TARGZ)
	docker run --rm -v $(CURDIR)/build:/build crystal-fpm /bin/sh -c "\
    mkdir -p /tmp/crystal \
    && tar -C /tmp/crystal -xf $(LOCAL_CRYSTAL_LINUX64_TARGZ) \
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

$(OUTPUT_DIR)/$(DEB_NAME32): docker-fpm $(LOCAL_CRYSTAL_LINUX32_TARGZ)
	docker run --rm -v $(CURDIR)/build:/build crystal-fpm /bin/sh -c "\
    mkdir -p /tmp/crystal \
    && tar -C /tmp/crystal -xf $(LOCAL_CRYSTAL_LINUX32_TARGZ) \
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
