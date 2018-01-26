CRYSTAL_VERSION ?= ## How the binaries should be branded
CRYSTAL_SHA1 ?=    ## Git tag/branch/sha1 to checkout and build source
PREVIOUS_CRYSTAL_RELEASE = https://github.com/crystal-lang/crystal/releases/download/v0.24.1/crystal-0.24.1-2-linux-x86_64.tar.gz

OUTPUT_DIR = build
OUTPUT_DOCS_BASE_NAME = crystal-$(CRYSTAL_VERSION)-docs

BUILD_ARGS = --build-arg output_docs_base_name=$(OUTPUT_DOCS_BASE_NAME) --build-arg crystal_sha1=$(CRYSTAL_SHA1) --build-arg previous_crystal_release=$(PREVIOUS_CRYSTAL_RELEASE)

.PHONY: all
all: $(OUTPUT_DIR)/$(OUTPUT_DOCS_BASE_NAME).tar.gz

$(OUTPUT_DIR)/$(OUTPUT_DOCS_BASE_NAME).tar.gz:
	mkdir -p $(OUTPUT_DIR)
	docker build $(BUILD_ARGS) -t crystal-build-temp .
	container_id="$$(docker create crystal-build-temp)" \
	  && docker cp "$$container_id":/output/$(OUTPUT_DOCS_BASE_NAME).tar.gz $(OUTPUT_DIR)/ \
	  && docker rm -v "$$container_id"

.PHONY: clean
clean: ## Clean up build directory
	rm -Rf $(OUTPUT_DIR)
