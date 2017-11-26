CRYSTAL_VERSION = 0.24.0
PACKAGE_ITERATION = 1
SHARDS_VERSION = v0.7.2

GC_VERSION = v7.4.6
LIBATOMIC_OPS_VERSION = v7.4.8

LIBEVENT_VERSION = release-2.1.8-stable

OUTPUT_DIR = build
OUTPUT_BASENAME = $(OUTPUT_DIR)/crystal-$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION)-x86_64
FILES = files/crystal-wrapper files/ysbaddaden.pub

DEB_NAME = crystal_$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION)_amd64.deb
RPM_NAME = crystal-$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION).x86_64.rpm

BUILD_ARGS = $(if $(no_cache),--no-cache )$(if $(pull_images),--pull )$(if $(release),--build-arg release=true )--build-arg crystal_version=$(CRYSTAL_VERSION) --build-arg shards_version=$(SHARDS_VERSION) --build-arg gc_version=$(GC_VERSION) --build-arg libatomic_ops_version=$(LIBATOMIC_OPS_VERSION) --build-arg libevent_version=$(LIBEVENT_VERSION)

.PHONY: all
all: package

.PHONY: build
build: $(OUTPUT_BASENAME).tar

$(OUTPUT_BASENAME).tar: Dockerfile $(FILES)
	mkdir -p $(OUTPUT_DIR)
	docker build $(BUILD_ARGS) -t crystal-build-temp .
	container_id="$$(docker create crystal-build-temp)" \
	  && docker cp "$$container_id":/output/crystal-$(CRYSTAL_VERSION).tar $(OUTPUT_BASENAME).tar \
	  && docker rm -v "$$container_id"

.PHONY: compress
compress: $(OUTPUT_BASENAME).tar.gz $(OUTPUT_BASENAME).tar.xz

$(OUTPUT_BASENAME).tar.gz: $(OUTPUT_BASENAME).tar
	gzip -c $(OUTPUT_BASENAME).tar > $(OUTPUT_BASENAME).tar.gz

$(OUTPUT_BASENAME).tar.xz: $(OUTPUT_BASENAME).tar
	xz -T 0 -c $(OUTPUT_BASENAME).tar > $(OUTPUT_BASENAME).tar.xz

.PHONY: package
package: compress $(OUTPUT_DIR)/$(DEB_NAME) $(OUTPUT_DIR)/$(RPM_NAME)

$(OUTPUT_DIR)/$(DEB_NAME): $(OUTPUT_BASENAME).tar
	tmpdir=$$(mktemp -d) \
    && tar -C $$tmpdir -xf $(OUTPUT_BASENAME).tar \
    && mv $$tmpdir/crystal-$(CRYSTAL_VERSION)/share/licenses/crystal/LICENSE $$tmpdir/crystal-$(CRYSTAL_VERSION)/share/doc/crystal/copyright \
    && rm -Rf $$tmpdir/crystal-*/share/licenses \
    && fpm --input-type dir --output-type deb \
           --name crystal --version $(CRYSTAL_VERSION) --iteration $(PACKAGE_ITERATION) \
           --architecture x86_64 --maintainer "Chris Hobbs <chris@rx14.co.uk>" \
           --depends gcc --depends libpcre3-dev --depends libevent-dev \
           --deb-recommends git --deb-recommends libssl-dev \
           --deb-suggests libxml2-dev --deb-suggests libgmp-dev --deb-suggests libyaml-dev --deb-suggests libreadline-dev \
           --force --package $(OUTPUT_DIR)/$(DEB_NAME) \
           --prefix /usr --chdir $$tmpdir/crystal-$(CRYSTAL_VERSION) bin lib share \
    && rm -Rf $$tempdir

$(OUTPUT_DIR)/$(RPM_NAME): $(OUTPUT_BASENAME).tar
	tmpdir=$$(mktemp -d) \
    && tar -C $$tmpdir -xf $(OUTPUT_BASENAME).tar \
    && fpm --input-type dir --output-type rpm \
           --name crystal --version $(CRYSTAL_VERSION) --iteration $(PACKAGE_ITERATION) \
           --architecture x86_64 --maintainer "Chris Hobbs <chris@rx14.co.uk>" \
           --depends gcc --depends pcre-devel --depends libevent-devel \
           --force --package $(OUTPUT_DIR)/$(RPM_NAME) \
           --prefix /usr --chdir $$tmpdir/crystal-$(CRYSTAL_VERSION) bin lib share \
    && rm -Rf $$tempdir

.PHONY: clean
clean:
	rm -Rf $(OUTPUT_DIR)
