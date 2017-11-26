CRYSTAL_VERSION = 0.24.0
SHARDS_VERSION = v0.7.2

GC_VERSION = v7.4.6
LIBATOMIC_OPS_VERSION = v7.4.8

LIBEVENT_VERSION = release-2.1.8-stable

OUTPUT_DIR = build
OUTPUT_BASENAME = $(OUTPUT_DIR)/crystal-$(CRYSTAL_VERSION)
FILES = files/crystal-wrapper files/ysbaddaden.pub

BUILD_ARGS = --build-arg crystal_version=$(CRYSTAL_VERSION) --build-arg shards_version=$(SHARDS_VERSION) --build-arg gc_version=$(GC_VERSION) --build-arg libatomic_ops_version=$(LIBATOMIC_OPS_VERSION) --build-arg libevent_version=$(LIBEVENT_VERSION)

.PHONY: all
dist: build

.PHONY: build
build: $(OUTPUT_BASENAME).tar

$(OUTPUT_BASENAME).tar: Dockerfile $(FILES)
	mkdir -p $(OUTPUT_DIR)
	docker build $(BUILD_ARGS) -t crystal-build-temp .
	container_id="$$(docker create crystal-build-temp)" \
	  && docker cp "$$container_id":/output/crystal-$(CRYSTAL_VERSION).tar $(OUTPUT_DIR) \
	  && docker rm -v "$$container_id"

.PHONY: compress
compress: $(OUTPUT_BASENAME).tar.gz $(OUTPUT_BASENAME).tar.xz

$(OUTPUT_BASENAME).tar.gz: $(OUTPUT_BASENAME).tar
	gzip -c $(OUTPUT_BASENAME).tar > $(OUTPUT_BASENAME).tar.gz

$(OUTPUT_BASENAME).tar.xz: $(OUTPUT_BASENAME).tar
	xz -T 0 -c $(OUTPUT_BASENAME).tar > $(OUTPUT_BASENAME).tar.xz

.PHONY: clean
clean:
	rm -Rf $(OUTPUT_DIR)
