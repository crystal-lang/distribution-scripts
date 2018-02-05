CRYSTAL_VERSION ?=      ## How the binaries should be branded
CRYSTAL_SHA1 ?=         ## Git tag/branch/sha1 to checkout and build source
CRYSTAL_DOCKER_IMAGE ?= ## Which crystal docker build image to use

OUTPUT_DIR = build
OUTPUT_DOCS_BASE_NAME = crystal-$(CRYSTAL_VERSION)-docs

BUILD_ARGS = --build-arg crystal_docker_image=$(CRYSTAL_DOCKER_IMAGE) --build-arg output_docs_base_name=$(OUTPUT_DOCS_BASE_NAME) --build-arg crystal_sha1=$(CRYSTAL_SHA1)

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
