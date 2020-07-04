-include Makefile.local # for local options BINTRAY_USERNAME, BINTRAY_API_KEY

# Secrets configuration
BINTRAY_USERNAME ?=
BINTRAY_API_KEY ?=
BINTRAY_SIGNING_PASSPHRASE ?= # Optional signing passphrase

# Public configuration
BINTRAY_SUBJECT  ?= crystal
BINTRAY_PACKAGE  ?= crystal
BINTRAY_DEB_REPO ?= deb
BINTRAY_RPM_REPO ?= rpm
BINTRAY_PACKAGE_VCS ?= https://github.com/crystal-lang/crystal.git
BINTRAY_PACKAGE_WEBSITE ?= http://crystal-lang.org/
# Possible channels are:
#
# - stable: for tagged releases
# - unstable: for -rc, -pre releases,
# - nightly: for nightly packages
#
CHANNEL ?= stable

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

DEB_DISTROS = all
PUBLISH_FLAGS = publish=1$(if $(force),;override=1)

CURL_BINTRAY_AUTH = -u$(BINTRAY_USERNAME):$(BINTRAY_API_KEY)
CURL_BINTRAY_PASSPHRASE = $(if $(BINTRAY_SIGNING_PASSPHRASE),-H "X-GPG-PASSPHRASE: $(BINTRAY_SIGNING_PASSPHRASE)")

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
	rm -Rf $(OUTPUT_DIR)/signed/*.deb

clean_rpm:
	rm -Rf $(OUTPUT_DIR)/unsigned/*.rpm
	rm -Rf $(OUTPUT_DIR)/signed/*.rpm

.PHONY: docker-fpm
docker-fpm: Dockerfile-fpm
	docker build $(DOCKER_BUILD_ARGS) -t crystal-fpm -f Dockerfile-fpm .

ALL_RPM_OUTPUTS =
ALL_RPM_PUBLISH =
ALL_RPM_CALC_METADATA =

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
    then ./sign.sh sign-$(1) $(2); \
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
	curl -T $(OUTPUT_SIGNED_DEB_NAME64) $(CURL_BINTRAY_AUTH) $(CURL_BINTRAY_PASSPHRASE) "https://api.bintray.com/content/$(BINTRAY_SUBJECT)/$(BINTRAY_DEB_REPO)/$(BINTRAY_PACKAGE)/$(CRYSTAL_VERSION)/$(DEB_NAME64);deb_distribution=$(DEB_DISTROS);deb_component=$(CHANNEL);deb_architecture=amd64;$(PUBLISH_FLAGS)"

.PHONY: deb32_publish
deb32_publish:
	curl -T $(OUTPUT_SIGNED_DEB_NAME32) $(CURL_BINTRAY_AUTH) $(CURL_BINTRAY_PASSPHRASE) "https://api.bintray.com/content/$(BINTRAY_SUBJECT)/$(BINTRAY_DEB_REPO)/$(BINTRAY_PACKAGE)/$(CRYSTAL_VERSION)/$(DEB_NAME32);deb_distribution=$(DEB_DISTROS);deb_component=$(CHANNEL);deb_architecture=i386;$(PUBLISH_FLAGS)"

$(OUTPUT_UNSIGNED_DEB_NAME64): docker-fpm $(OUTPUT_LINUX64_TARGZ)
	mkdir -p $(OUTPUT_UNSIGNED)
	docker run --rm -v $(CURDIR)/build:/build crystal-fpm /bin/sh -c "\
    mkdir -p /tmp/crystal \
    && tar -C /tmp/crystal --strip-components 1 -xf $(OUTPUT_LINUX64_TARGZ) \
    && mv /tmp/crystal/share/licenses/crystal/LICENSE /tmp/crystal/share/doc/crystal/copyright \
    && rm -Rf /tmp/crystal/share/licenses \
    && fpm --input-type dir --output-type deb \
           --architecture x86_64 \
           --depends gcc --depends pkg-config --depends libpcre3-dev --depends libevent-dev \
           --deb-recommends git --deb-recommends libssl-dev --deb-recommends libz-dev \
           --deb-suggests libxml2-dev --deb-suggests libgmp-dev --deb-suggests libyaml-dev --deb-suggests libreadline-dev \
           --force --package $(OUTPUT_UNSIGNED_DEB_NAME64) \
           --prefix /usr \
           --chdir /tmp/crystal \
           $(FPM_FLAGS) bin lib share"

$(OUTPUT_UNSIGNED_DEB_NAME32): docker-fpm $(OUTPUT_LINUX32_TARGZ)
	mkdir -p $(OUTPUT_UNSIGNED)
	docker run --rm -v $(CURDIR)/build:/build crystal-fpm /bin/sh -c "\
    mkdir -p /tmp/crystal \
    && tar -C /tmp/crystal --strip-components 1 -xf $(OUTPUT_LINUX32_TARGZ) \
    && mv /tmp/crystal/share/licenses/crystal/LICENSE /tmp/crystal/share/doc/crystal/copyright \
    && rm -Rf /tmp/crystal/share/licenses \
    && fpm --input-type dir --output-type deb \
           --architecture i386 \
           --depends gcc --depends pkg-config --depends libpcre3-dev --depends libevent-dev \
           --deb-recommends git --deb-recommends libssl-dev --deb-recommends libz-dev \
           --deb-suggests libxml2-dev --deb-suggests libgmp-dev --deb-suggests libyaml-dev --deb-suggests libreadline-dev \
           --force --package $(OUTPUT_UNSIGNED_DEB_NAME32) \
           --prefix /usr \
           --chdir /tmp/crystal \
           $(FPM_FLAGS) bin lib share"

define rpm_template # (distro,arch,extra-fpm-flags)
$(eval this_rpm_output_name = crystal-$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION).$(1).$(2).rpm)
$(eval this_unsigned_rpm_output = $(OUTPUT_UNSIGNED)/$(this_rpm_output_name))
$(eval this_signed_rpm_output = $(OUTPUT_SIGNED)/$(this_rpm_output_name))

$(eval ALL_RPM_OUTPUTS += $(this_signed_rpm_output))
$(eval ALL_RPM_PUBLISH += rpm_publish_$(1)_$(2))
$(eval ALL_RPM_CALC_METADATA += rpm_calc_metadata_$(1)_$(2))

$(this_unsigned_rpm_output): docker-fpm $(OUTPUT_LINUX64_TARGZ)
	mkdir -p $(OUTPUT_UNSIGNED)
	docker run --rm -v $(CURDIR)/build:/build crystal-fpm /bin/sh -c "\
    mkdir -p /tmp/crystal \
    && tar -C /tmp/crystal --strip-components 1 -xf $(OUTPUT_LINUX64_TARGZ) \
    && fpm --input-type dir --output-type rpm \
           --architecture $(2) \
           $(3) \
           --force --package $(this_unsigned_rpm_output) \
           --prefix /usr \
           --chdir /tmp/crystal \
           $(FPM_FLAGS) bin lib share"

$(this_signed_rpm_output): $(this_unsigned_rpm_output)
	$(call create_signed,rpm,$(this_unsigned_rpm_output))

.PHONY: rpm_publish_$(1)_$(2)
rpm_publish_$(1)_$(2):
	curl -T $(this_signed_rpm_output) $(CURL_BINTRAY_AUTH) $(CURL_BINTRAY_PASSPHRASE) "https://api.bintray.com/content/$(BINTRAY_SUBJECT)/$(BINTRAY_RPM_REPO)/$(BINTRAY_PACKAGE)/$(CRYSTAL_VERSION)/$(1)/$(2)/$(CHANNEL)/$(this_rpm_output_name);$(PUBLISH_FLAGS)"

.PHONY: rpm_calc_metadata_$(1)_$(2)
rpm_calc_metadata_$(1)_$(2):
	curl -X POST $(CURL_BINTRAY_AUTH) "https://api.bintray.com/calc_metadata/crystal/rpm/$(1)/$(2)/$(CHANNEL)"
endef

# It would be great to use --depends 'libevent-devel >= 2.0 or libevent2-devel', but
# * CentOS 6/7 have rpm <= 4.13 which does not support expressions https://rpm.org/user_doc/boolean_dependencies.html
# * CentOS 7/8 does not have libevent2-devel. Only CentOS 6 uses libevent2-devel.
$(eval $(call rpm_template,el6,x86_64,--depends gcc --depends pkgconfig --depends pcre-devel --depends libevent2-devel))
$(eval $(call rpm_template,all,x86_64,--depends gcc --depends pkgconfig --depends pcre-devel --depends libevent-devel))

.PHONY: rpm
rpm: $(ALL_RPM_OUTPUTS)

.PHONY: rpm_publish
rpm_publish: $(ALL_RPM_PUBLISH)

.PHONY: rpm_calc_metadata
rpm_calc_metadata: $(ALL_RPM_CALC_METADATA)

# Other Bintray API

.PHONY: create_bintray_deb_repo
create_bintray_deb_repo:
	curl --data '{"type":"debian","gpg_sign_metadata":true,"gpg_sign_files":false,"gpg_use_owner_key":false}' -H "Content-Type: application/json" -X POST $(CURL_BINTRAY_AUTH) "https://api.bintray.com/repos/$(BINTRAY_SUBJECT)/$(BINTRAY_DEB_REPO)"
	curl --data '{"name":"$(BINTRAY_PACKAGE)","licenses": ["Apache-2.0"],"vcs_url":"$(BINTRAY_PACKAGE_VCS)","website_url":"$(BINTRAY_PACKAGE_WEBSITE)"}' -H "Content-Type: application/json" -X POST $(CURL_BINTRAY_AUTH) "https://api.bintray.com/packages/$(BINTRAY_SUBJECT)/$(BINTRAY_DEB_REPO)"

.PHONY: create_bintray_rpm_repo
create_bintray_rpm_repo:
    # yum_metadata_depth=3 : DISTRO/ARCH/CHANNEL
	curl --data '{"type":"rpm","yum_metadata_depth":3,"gpg_sign_metadata":true,"gpg_sign_files":false,"gpg_use_owner_key":false}' -H "Content-Type: application/json" -X POST $(CURL_BINTRAY_AUTH) "https://api.bintray.com/repos/$(BINTRAY_SUBJECT)/$(BINTRAY_RPM_REPO)"
	curl --data '{"name":"$(BINTRAY_PACKAGE)","licenses": ["Apache-2.0"],"vcs_url":"$(BINTRAY_PACKAGE_VCS)","website_url":"$(BINTRAY_PACKAGE_WEBSITE)"}' -H "Content-Type: application/json" -X POST $(CURL_BINTRAY_AUTH) "https://api.bintray.com/packages/$(BINTRAY_SUBJECT)/$(BINTRAY_RPM_REPO)"

# $ make set_version_date CRYSTAL_VERSION=0.33.0 CRYSTAL_VERSION_DATE=2020-02-14
.PHONY: set_version_date
set_version_date:
	curl -v --data '{"released": "$(CRYSTAL_VERSION_DATE)T12:00:00.000Z"}' -H "Content-Type: application/json" -X PATCH $(CURL_BINTRAY_AUTH) "https://api.bintray.com/packages/$(BINTRAY_SUBJECT)/$(BINTRAY_DEB_REPO)/$(BINTRAY_PACKAGE)/versions/$(CRYSTAL_VERSION)"
	curl -v --data '{"released": "$(CRYSTAL_VERSION_DATE)T12:00:00.000Z"}' -H "Content-Type: application/json" -X PATCH $(CURL_BINTRAY_AUTH) "https://api.bintray.com/packages/$(BINTRAY_SUBJECT)/$(BINTRAY_RPM_REPO)/$(BINTRAY_PACKAGE)/versions/$(CRYSTAL_VERSION)"
