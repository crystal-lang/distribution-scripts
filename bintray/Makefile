-include Makefile.local # for local options BINTRAY_USERNAME, BINTRAY_API_KEY

# Secrets configuration
BINTRAY_USERNAME ?=
BINTRAY_API_KEY ?=
BINTRAY_SINGING_PASSPHRASE ?= # Optional signing passphrase

# Public configuration
BINTRAY_SUBJECT  ?= crystal
BINTRAY_PACKAGE  ?= crystal
BINTRAY_APT_REPO ?= apt
BINTRAY_RPM_REPO ?= rpm
BINTRAY_PACKAGE_VCS ?= https://github.com/crystal-lang/crystal.git
BINTRAY_PACKAGE_WEBSITE ?= http://crystal-lang.org/

# Package build configuration
sign ?= true               ## Sign the .deb and .rpm files using ./sign.sh
force ?=                   ## Force publish of existing file
CRYSTAL_LINUX64_TARGZ   ?= ## url or path to crystal-{version}-{package}-linux-x86_64.tar.gz
CRYSTAL_LINUX32_TARGZ   ?= ## url or path to crystal-{version}-{package}-linux-i686.tar.gz

# Package branding configuration
CRYSTAL_VERSION   ?=   ## How the binaries should be branded
PACKAGE_ITERATION ?= 1
PACKAGE_MAINTAINER ?= Crystal Team <crystal@manas.tech>

OUTPUT_TARGZ = $(OUTPUT_DIR)/targz
OUTPUT_UNSIGNED = $(OUTPUT_DIR)/unsigned
OUTPUT_SIGNED = $(OUTPUT_DIR)/signed
OUTPUT_LINUX64_TARGZ = $(OUTPUT_TARGZ)/crystal-$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION)-linux-x86_64.tar.gz
OUTPUT_LINUX32_TARGZ = $(OUTPUT_TARGZ)/crystal-$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION)-linux-i686.tar.gz
DEB_NAME64 = crystal_$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION)_amd64.deb
DEB_NAME32 = crystal_$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION)_i386.deb
OUTPUT_UNSIGNED_DEB_NAME64 = $(OUTPUT_UNSIGNED)/$(DEB_NAME64)
OUTPUT_UNSIGNED_DEB_NAME32 = $(OUTPUT_UNSIGNED)/$(DEB_NAME32)
OUTPUT_SIGNED_DEB_NAME64 = $(OUTPUT_SIGNED)/$(DEB_NAME64)
OUTPUT_SIGNED_DEB_NAME32 = $(OUTPUT_SIGNED)/$(DEB_NAME32)

DEB_DISTROS = jessie,stretch,buster,trusty,xenial,bionic,eoan
PUBLISH_FLAGS = publish=1$(if $(force),;override=1)

CURL_BINTRAY_AUTH = -u$(BINTRAY_USERNAME):$(BINTRAY_API_KEY)
CURL_BINTRAY_PASSPHRASE = $(if $(BINTRAY_SINGING_PASSPHRASE),-H "X-GPG-PASSPHRASE: $(BINTRAY_SINGING_PASSPHRASE)")

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

clean_targz:
	rm -Rf $(OUTPUT_TARGZ)

clean_deb:
	rm -Rf $(OUTPUT_DIR)/unsigned/*.deb

clean_rpm:
	rm -Rf $(OUTPUT_DIR)/unsigned/*.rpm

clean_signed:
	rm -Rf $(OUTPUT_DIR)/signed/*.deb
	rm -Rf $(OUTPUT_DIR)/signed/*.rpm

.PHONY: docker-fpm
docker-fpm: Dockerfile-fpm
	docker build $(DOCKER_BUILD_ARGS) -t crystal-fpm -f Dockerfile-fpm .

ALL_RPM_OUTPUTS =
ALL_RPM_PUBLISH =

.PHONY: all
all: targz deb rpm

.PHONY: publish
publish: rpm_publish deb_publish

define download_or_copy
	mkdir -p $(OUTPUT_TARGZ)
	if [[ "$(1)" =~ ^http(s?):\/\/ ]]; \
	then curl -L -o $(2) "$(1)"; \
	else cp "$(1)" $(2); \
	fi
endef

define create_signed # (rpm|deb, path/to/unsigned.[rpm|deb])
    if [[ "$(strip $(sign))" == "true" ]]; \
    then ./sign.sh sign-"$(1)" $(2); \
    else ./sign.sh skip-sign $(2); \
    fi
endef

.PHONY: targz
targz: $(OUTPUT_LINUX64_TARGZ) $(OUTPUT_LINUX32_TARGZ)

$(OUTPUT_LINUX64_TARGZ):
	$(call download_or_copy,$(CRYSTAL_LINUX64_TARGZ),$(OUTPUT_LINUX64_TARGZ))

$(OUTPUT_LINUX32_TARGZ):
	$(call download_or_copy,$(CRYSTAL_LINUX32_TARGZ),$(OUTPUT_LINUX32_TARGZ))

$(OUTPUT_SIGNED_DEB_NAME64): $(OUTPUT_UNSIGNED_DEB_NAME64)
	$(call create_signed,deb,$(OUTPUT_UNSIGNED_DEB_NAME64))

$(OUTPUT_SIGNED_DEB_NAME32): $(OUTPUT_UNSIGNED_DEB_NAME32)
	$(call create_signed,deb,$(OUTPUT_UNSIGNED_DEB_NAME32))

.PHONY: deb
deb: deb64 deb32

.PHONY: deb64
deb64: $(OUTPUT_SIGNED_DEB_NAME64)

.PHONY: deb32
deb32: $(OUTPUT_SIGNED_DEB_NAME32)

.PHONY: deb_publish
deb_publish: deb64_publish deb32_publish

.PHONY: deb64_publish
deb64_publish:
	curl -T $(OUTPUT_SIGNED_DEB_NAME64) $(CURL_BINTRAY_AUTH) $(CURL_BINTRAY_PASSPHRASE) "https://api.bintray.com/content/$(BINTRAY_SUBJECT)/$(BINTRAY_APT_REPO)/$(BINTRAY_PACKAGE)/$(CRYSTAL_VERSION)/$(DEB_NAME64);deb_distribution=$(DEB_DISTROS);deb_component=main;deb_architecture=amd64;$(PUBLISH_FLAGS)"

.PHONY: deb32_publish
deb32_publish:
	curl -T $(OUTPUT_SIGNED_DEB_NAME32) $(CURL_BINTRAY_AUTH) $(CURL_BINTRAY_PASSPHRASE) "https://api.bintray.com/content/$(BINTRAY_SUBJECT)/$(BINTRAY_APT_REPO)/$(BINTRAY_PACKAGE)/$(CRYSTAL_VERSION)/$(DEB_NAME32);deb_distribution=$(DEB_DISTROS);deb_component=main;deb_architecture=i386;$(PUBLISH_FLAGS)"

$(OUTPUT_UNSIGNED_DEB_NAME64): docker-fpm $(OUTPUT_LINUX64_TARGZ)
	mkdir -p $(OUTPUT_UNSIGNED)
	docker run --rm -v $(CURDIR)/build:/build crystal-fpm /bin/sh -c "\
    mkdir -p /tmp/crystal \
    && tar -C /tmp/crystal -xf $(OUTPUT_LINUX64_TARGZ) \
    && mv /tmp/crystal/crystal-$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION)/share/licenses/crystal/LICENSE /tmp/crystal/crystal-$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION)/share/doc/crystal/copyright \
    && rm -Rf /tmp/crystal/crystal-*/share/licenses \
    && fpm --input-type dir --output-type deb \
           --architecture x86_64 \
           --depends gcc --depends pkg-config --depends libpcre3-dev --depends libevent-dev \
           --deb-recommends git --deb-recommends libssl-dev --deb-recommends libz-dev \
           --deb-suggests libxml2-dev --deb-suggests libgmp-dev --deb-suggests libyaml-dev --deb-suggests libreadline-dev \
           --force --package $(OUTPUT_UNSIGNED_DEB_NAME64) \
           --prefix /usr \
           --chdir /tmp/crystal/crystal-$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION) \
           $(FPM_FLAGS) bin lib share"

$(OUTPUT_UNSIGNED_DEB_NAME32): docker-fpm $(OUTPUT_LINUX32_TARGZ)
	mkdir -p $(OUTPUT_UNSIGNED)
	docker run --rm -v $(CURDIR)/build:/build crystal-fpm /bin/sh -c "\
    mkdir -p /tmp/crystal \
    && tar -C /tmp/crystal -xf $(OUTPUT_LINUX32_TARGZ) \
    && mv /tmp/crystal/crystal-$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION)/share/licenses/crystal/LICENSE /tmp/crystal/crystal-$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION)/share/doc/crystal/copyright \
    && rm -Rf /tmp/crystal/crystal-*/share/licenses \
    && fpm --input-type dir --output-type deb \
           --architecture i386 \
           --depends gcc --depends pkg-config --depends libpcre3-dev --depends libevent-dev \
           --deb-recommends git --deb-recommends libssl-dev --deb-recommends libz-dev \
           --deb-suggests libxml2-dev --deb-suggests libgmp-dev --deb-suggests libyaml-dev --deb-suggests libreadline-dev \
           --force --package $(OUTPUT_UNSIGNED_DEB_NAME32) \
           --prefix /usr \
           --chdir /tmp/crystal/crystal-$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION) \
           $(FPM_FLAGS) bin lib share"

define rpm_template # (distro,extra-fpm-flags)
$(eval this_rpm_output_name = crystal-$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION).$(1).x86_64.rpm)
$(eval this_unsigned_rpm_output = $(OUTPUT_UNSIGNED)/$(this_rpm_output_name))
$(eval this_signed_rpm_output = $(OUTPUT_SIGNED)/$(this_rpm_output_name))

$(eval ALL_RPM_OUTPUTS += $(this_signed_rpm_output))
$(eval ALL_RPM_PUBLISH += rpm_publish_$(1))

$(this_unsigned_rpm_output): docker-fpm $(OUTPUT_LINUX64_TARGZ)
	mkdir -p $(OUTPUT_UNSIGNED)
	docker run --rm -v $(CURDIR)/build:/build crystal-fpm /bin/sh -c "\
    mkdir -p /tmp/crystal \
    && tar -C /tmp/crystal -xf $(OUTPUT_LINUX64_TARGZ) \
    && fpm --input-type dir --output-type rpm \
           --architecture x86_64 \
           --rpm-dist $(1) $(2) \
           --force --package $(this_unsigned_rpm_output) \
           --prefix /usr \
           --chdir /tmp/crystal/crystal-$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION) \
           $(FPM_FLAGS) bin lib share"

$(this_signed_rpm_output): $(this_unsigned_rpm_output)
	$(call create_signed,rpm,$(this_unsigned_rpm_output))

.PHONY: rpm_publish_$(1)
rpm_publish_$(1):
	curl -T $(this_signed_rpm_output) $(CURL_BINTRAY_AUTH) $(CURL_BINTRAY_PASSPHRASE) "https://api.bintray.com/content/$(BINTRAY_SUBJECT)/$(BINTRAY_RPM_REPO)/$(BINTRAY_PACKAGE)/$(CRYSTAL_VERSION)/$(1)/$(this_rpm_output_name);$(PUBLISH_FLAGS)"
endef

$(eval $(call rpm_template,el6,--depends gcc --depends pkgconfig --depends pcre-devel --depends libevent2-devel))
$(eval $(call rpm_template,fc30,--depends gcc --depends pkgconfig --depends pcre-devel --depends libevent-devel))

.PHONY: rpm
rpm: $(ALL_RPM_OUTPUTS)

.PHONY: rpm_publish
rpm_publish: $(ALL_RPM_PUBLISH)

# Other Bintray API

.PHONY: create_bintray_apt_repo
create_bintray_apt_repo:
	curl --data '{"type":"debian","gpg_sign_metadata":true,"gpg_sign_files":false,"gpg_use_owner_key":false}' -H "Content-Type: application/json" -X POST $(CURL_BINTRAY_AUTH) "https://api.bintray.com/repos/$(BINTRAY_SUBJECT)/$(BINTRAY_APT_REPO)"
	curl --data '{"name":"$(BINTRAY_PACKAGE)","licenses": ["Apache-2.0"],"vcs_url":"$(BINTRAY_PACKAGE_VCS)","website_url":"$(BINTRAY_PACKAGE_WEBSITE)"}' -H "Content-Type: application/json" -X POST $(CURL_BINTRAY_AUTH) "https://api.bintray.com/packages/$(BINTRAY_SUBJECT)/$(BINTRAY_APT_REPO)"

.PHONY: create_bintray_rpm_repo
create_bintray_rpm_repo:
	curl --data '{"type":"rpm","yum_metadata_depth":1,"gpg_sign_metadata":true,"gpg_sign_files":false,"gpg_use_owner_key":false}' -H "Content-Type: application/json" -X POST $(CURL_BINTRAY_AUTH) "https://api.bintray.com/repos/$(BINTRAY_SUBJECT)/$(BINTRAY_RPM_REPO)"
	curl --data '{"name":"$(BINTRAY_PACKAGE)","licenses": ["Apache-2.0"],"vcs_url":"$(BINTRAY_PACKAGE_VCS)","website_url":"$(BINTRAY_PACKAGE_WEBSITE)"}' -H "Content-Type: application/json" -X POST $(CURL_BINTRAY_AUTH) "https://api.bintray.com/packages/$(BINTRAY_SUBJECT)/$(BINTRAY_RPM_REPO)"

# $ make set_version_date CRYSTAL_VERSION=0.33.0 CRYSTAL_VERSION_DATE=2020-02-14
.PHONY: set_version_date
set_version_date:
	curl -v --data '{"released": "$(CRYSTAL_VERSION_DATE)T12:00:00.000Z"}' -H "Content-Type: application/json" -X PATCH $(CURL_BINTRAY_AUTH) "https://api.bintray.com/packages/$(BINTRAY_SUBJECT)/$(BINTRAY_APT_REPO)/$(BINTRAY_PACKAGE)/versions/$(CRYSTAL_VERSION)"
	curl -v --data '{"released": "$(CRYSTAL_VERSION_DATE)T12:00:00.000Z"}' -H "Content-Type: application/json" -X PATCH $(CURL_BINTRAY_AUTH) "https://api.bintray.com/packages/$(BINTRAY_SUBJECT)/$(BINTRAY_RPM_REPO)/$(BINTRAY_PACKAGE)/versions/$(CRYSTAL_VERSION)"
