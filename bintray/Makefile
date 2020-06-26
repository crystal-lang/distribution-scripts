-include Makefile.local # for local options BINTRAY_USERNAME, BINTRAY_API_KEY

# bintray repo configuration
#
# apt
#   * Sign using: User's / Organization's GPG private key
#   * Content: All files
#
# rpm
#   * YUM metadata folder depth: 1
#   * Sign using: User's / Organization's GPG private key
#   * Content: All files
#
# create crystal package on both
#   * Website: http://crystal-lang.org/
#   * Version control: https://github.com/crystal-lang/crystal

# Secrets configuration
BINTRAY_USERNAME ?=
BINTRAY_API_KEY ?=
BINTRAY_SINGING_PASSPHRASE ?=

# Public configuration
BINTRAY_ORG      ?= crystal
BINTRAY_PACKAGE  ?= crystal
BINTRAY_APT_REPO ?= apt
BINTRAY_RPM_REPO ?= rpm

# Package build configuration
force ?=                   ## Force publish of existing file
CRYSTAL_LINUX64_TARGZ   ?= ## url or path to crystal-{version}-{package}-linux-x86_64.tar.gz
CRYSTAL_LINUX32_TARGZ   ?= ## url or path to crystal-{version}-{package}-linux-i686.tar.gz

# Package branding configuration
CRYSTAL_VERSION   ?=   ## How the binaries should be branded
PACKAGE_ITERATION ?= 1
PACKAGE_MAINTAINER ?= Crystal Team <crystal@manas.tech>

FPM_FLAGS = --name $(BINTRAY_PACKAGE) \
            --version $(CRYSTAL_VERSION) \
            --iteration $(PACKAGE_ITERATION) \
            --vendor \"$(PACKAGE_MAINTAINER)\" \
            --maintainer \"$(PACKAGE_MAINTAINER)\" \
            --url \"https://crystal-lang.org/\" \
            --description \"Crystal programming language compiler\" \
            --license APACHE-2.0 \
            --provides crystal --provides shards


OUTPUT_DIR = build

SHELL := /bin/bash

clean:
	rm -Rf $(OUTPUT_DIR)

clean_deb:
	rm -Rf $(OUTPUT_DIR)/*.deb

clean_rpm:
	rm -Rf $(OUTPUT_DIR)/*.deb

.PHONY: docker-fpm
docker-fpm: Dockerfile-fpm
	docker build $(DOCKER_BUILD_ARGS) -t crystal-fpm -f Dockerfile-fpm .

LINUX64_TARGZ = crystal-$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION)-linux-x86_64.tar.gz
LINUX32_TARGZ = crystal-$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION)-linux-i686.tar.gz
DEB_NAME64 = crystal_$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION)_amd64.deb
DEB_NAME32 = crystal_$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION)_i386.deb
DEB_DISTROS = jessie,stretch,buster,trusty,xenial,bionic,eoan
ALL_RPM_OUTPUTS =
ALL_RPM_PUBLISH =
PUBLISH_FLAGS = publish=1$(if $(force),;override=1)

CURL_BINTRAY_AUTH = -u$(BINTRAY_USERNAME):$(BINTRAY_API_KEY)
CURL_BINTRAY_PASSPHRASE = -H "X-GPG-PASSPHRASE: $(BINTRAY_SINGING_PASSPHRASE)"

.PHONY: all
all: targz deb rpm

.PHONY: publish
publish: rpm_publish deb_publish

define download_or_copy
	mkdir -p $(OUTPUT_DIR)
	if [[ "$(1)" =~ ^http(s?):\/\/ ]]; \
	then curl -L -o $(2) "$(1)"; \
	else cp "$(1)" $(2); \
	fi
endef

.PHONY: targz
targz: $(OUTPUT_DIR)/$(LINUX64_TARGZ) $(OUTPUT_DIR)/$(LINUX32_TARGZ)

$(OUTPUT_DIR)/$(LINUX64_TARGZ):
	$(call download_or_copy,$(CRYSTAL_LINUX64_TARGZ),$(OUTPUT_DIR)/$(LINUX64_TARGZ))

$(OUTPUT_DIR)/$(LINUX32_TARGZ):
	$(call download_or_copy,$(CRYSTAL_LINUX32_TARGZ),$(OUTPUT_DIR)/$(LINUX32_TARGZ))

.PHONY: deb
deb: $(OUTPUT_DIR)/$(DEB_NAME64) $(OUTPUT_DIR)/$(DEB_NAME32)

.PHONY: deb_publish
deb_publish:
	curl -T $(OUTPUT_DIR)/$(DEB_NAME64) $(CURL_BINTRAY_AUTH) $(CURL_BINTRAY_PASSPHRASE) "https://api.bintray.com/content/$(BINTRAY_ORG)/$(BINTRAY_APT_REPO)/$(BINTRAY_PACKAGE)/$(CRYSTAL_VERSION)/$(DEB_NAME64);deb_distribution=$(DEB_DISTROS);deb_component=main;deb_architecture=amd64;$(PUBLISH_FLAGS)"
	curl -T $(OUTPUT_DIR)/$(DEB_NAME32) $(CURL_BINTRAY_AUTH) $(CURL_BINTRAY_PASSPHRASE) "https://api.bintray.com/content/$(BINTRAY_ORG)/$(BINTRAY_APT_REPO)/$(BINTRAY_PACKAGE)/$(CRYSTAL_VERSION)/$(DEB_NAME32);deb_distribution=$(DEB_DISTROS);deb_component=main;deb_architecture=i386;$(PUBLISH_FLAGS)"

# $ make set_version_date CRYSTAL_VERSION=0.33.0 CRYSTAL_VERSION_DATE=2020-02-14
.PHONY: set_version_date
set_version_date:
	curl -v --data '{"released": "$(CRYSTAL_VERSION_DATE)T12:00:00.000Z"}' -H "Content-Type: application/json" -X PATCH $(CURL_BINTRAY_AUTH) "https://api.bintray.com/packages/$(BINTRAY_ORG)/$(BINTRAY_APT_REPO)/$(BINTRAY_PACKAGE)/versions/$(CRYSTAL_VERSION)"
	curl -v --data '{"released": "$(CRYSTAL_VERSION_DATE)T12:00:00.000Z"}' -H "Content-Type: application/json" -X PATCH $(CURL_BINTRAY_AUTH) "https://api.bintray.com/packages/$(BINTRAY_ORG)/$(BINTRAY_RPM_REPO)/$(BINTRAY_PACKAGE)/versions/$(CRYSTAL_VERSION)"

$(OUTPUT_DIR)/$(DEB_NAME64): docker-fpm $(OUTPUT_DIR)/$(LINUX64_TARGZ)
	docker run --rm -v $(CURDIR)/build:/build crystal-fpm /bin/sh -c "\
    mkdir -p /tmp/crystal \
    && tar -C /tmp/crystal -xf $(OUTPUT_DIR)/$(LINUX64_TARGZ) \
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

$(OUTPUT_DIR)/$(DEB_NAME32): docker-fpm $(OUTPUT_DIR)/$(LINUX32_TARGZ)
	docker run --rm -v $(CURDIR)/build:/build crystal-fpm /bin/sh -c "\
    mkdir -p /tmp/crystal \
    && tar -C /tmp/crystal -xf $(OUTPUT_DIR)/$(LINUX32_TARGZ) \
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

define rpm_template # (distro,extra-fpm-flags)
$(eval this_rpm_output_name = crystal-$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION).$(1).x86_64.rpm)
$(eval this_rpm_output = $(OUTPUT_DIR)/$(this_rpm_output_name))

$(eval ALL_RPM_OUTPUTS += $(this_rpm_output))
$(eval ALL_RPM_PUBLISH += rpm_publish_$(1))

$(this_rpm_output): docker-fpm $(OUTPUT_DIR)/$(LINUX64_TARGZ)
	docker run --rm -v $(CURDIR)/build:/build crystal-fpm /bin/sh -c "\
    mkdir -p /tmp/crystal \
    && tar -C /tmp/crystal -xf $(OUTPUT_DIR)/$(LINUX64_TARGZ) \
    && fpm --input-type dir --output-type rpm \
           --architecture x86_64 $(PACKAGE_BRANDING_ARGS) \
           --rpm-dist $(1) $(2) \
           --force --package $(this_rpm_output) \
           --prefix /usr \
           --chdir /tmp/crystal/crystal-$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION) \
           $(FPM_FLAGS) bin lib share"

.PHONY: rpm_publish_$(1)
rpm_publish_$(1):
	curl -T $(this_rpm_output) $(CURL_BINTRAY_AUTH) $(CURL_BINTRAY_PASSPHRASE) "https://api.bintray.com/content/$(BINTRAY_ORG)/$(BINTRAY_RPM_REPO)/$(BINTRAY_PACKAGE)/$(CRYSTAL_VERSION)/$(1)/$(this_rpm_output_name);$(PUBLISH_FLAGS)"
endef

$(eval $(call rpm_template,el6,--depends gcc --depends pkgconfig --depends pcre-devel --depends libevent2-devel))
$(eval $(call rpm_template,fc30,--depends gcc --depends pkgconfig --depends pcre-devel --depends libevent-devel))

.PHONY: rpm
rpm: $(ALL_RPM_OUTPUTS)

.PHONY: rpm_publish
rpm_publish: $(ALL_RPM_PUBLISH)
