CRYSTAL_VERSION ?= ## How the binaries should be branded
CRYSTAL_DEB ?=     ## which crystal.deb file to install in the docker images

OUTPUT_DIR = build
BUILD_ARGS = --build-arg crystal_deb=$(CRYSTAL_DEB)

.PHONY: all
all: $(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION).tar.gz $(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-build.tar.gz

$(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION).tar.gz:
	mkdir -p $(OUTPUT_DIR)
	docker build $(BUILD_ARGS) --target runtime -t crystallang/crystal:$(CRYSTAL_VERSION) .
	docker save crystallang/crystal:$(CRYSTAL_VERSION) | gzip > $(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION).tar.gz

$(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-build.tar.gz: $(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION).tar.gz
	mkdir -p $(OUTPUT_DIR)
	docker build $(BUILD_ARGS) --target build -t crystallang/crystal:$(CRYSTAL_VERSION)-build .
	docker save crystallang/crystal:$(CRYSTAL_VERSION)-build | gzip > $(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-build.tar.gz

.PHONY: clean
clean: ## Clean up build directory
	rm -Rf $(OUTPUT_DIR)
