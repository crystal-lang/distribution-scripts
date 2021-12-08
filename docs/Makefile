CRYSTAL_VERSION ?=                 ## How the binaries should be branded
CRYSTAL_SHA1 ?= $(CRYSTAL_VERSION) ## Git tag/branch/sha1 to checkout and build source (default: `$(CRYSTAL_VERSION)`)
CRYSTAL_DOCKER_IMAGE ?= crystallang/crystal:$(CRYSTAL_VERSION)-build ## Which crystal docker build image to use (default: `$(CRYSTAL_VERSION)-build`)

OUTPUT_DIR = build
OUTPUT_DOCS_BASE_NAME = crystal-$(CRYSTAL_VERSION)-docs

AWS_CLI = docker run --rm -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -v $$(pwd):/mnt -w /mnt amazon/aws-cli:2.2.44
S3_ENDPOINT = s3://$(AWS_BUCKET)/api
AWS_BUCKET = crystal-api

BUILD_ARGS = --build-arg crystal_docker_image=$(CRYSTAL_DOCKER_IMAGE) --build-arg output_docs_base_name=$(OUTPUT_DOCS_BASE_NAME) --build-arg crystal_sha1=$(CRYSTAL_SHA1)

.PHONY: all
all: $(OUTPUT_DIR)/$(OUTPUT_DOCS_BASE_NAME).tar.gz ## Build docs tarball

$(OUTPUT_DIR)/$(OUTPUT_DOCS_BASE_NAME).tar.gz: $(OUTPUT_DIR)
	docker build $(BUILD_ARGS) -t crystal-build-temp .
	container_id="$$(docker create crystal-build-temp)" \
	  && docker cp "$$container_id":/output/$(OUTPUT_DOCS_BASE_NAME).tar.gz $(OUTPUT_DIR)/ \
	  && docker cp "$$container_id":/output/versions.json $(OUTPUT_DIR)/versions-$(CRYSTAL_VERSION).json \
	  && docker rm -v "$$container_id"

$(OUTPUT_DIR):
	mkdir -p $(OUTPUT_DIR)

.PHONY: clean
clean: ## Clean up build directory
	rm -Rf $(OUTPUT_DIR)

.PHONE: publish_docs
publish_docs: dist-docs dist-docs_versions ## Publish API docs to S3

.PHONY: dist-docs
dist-docs: $(OUTPUT_DIR)/api-$(CRYSTAL_VERSION) ## Sync API docs to `s3://$(AWS_BUCKET)/api/$(CRYSTAL_VERSION)`
	$(AWS_CLI) s3 sync "$</" "$(S3_ENDPOINT)/$(CRYSTAL_VERSION)/"

$(OUTPUT_DIR)/api-$(CRYSTAL_VERSION): $(OUTPUT_DIR)/$(OUTPUT_DOCS_BASE_NAME).tar.gz
	mkdir -p $@
	rm -rf $@/*
	tar -xzf $< -C $@ --strip-component=2

.PHONY: dist-docs_versions
dist-docs_versions: $(OUTPUT_DIR)/versions-$(CRYSTAL_VERSION).json ## Update `/versions.json` in S3
	$(AWS_CLI) s3 cp "$<" "$(S3_ENDPOINT)/versions.json"

$(OUTPUT_DIR)/versions-$(CRYSTAL_VERSION).json: $(OUTPUT_DIR)/$(OUTPUT_DOCS_BASE_NAME).tar.gz

.PHONY: dist-redirect_latest
dist-redirect_latest: $(OUTPUT_DIR)/aws-config.json ## Apply redirect from `api/latest` to `api/$(CRYSTAL_VERSION)` in S3 (needs to be manually applied)
	$(AWS_CLI) s3api put-bucket-website --bucket "$(AWS_BUCKET)" --website-configuration "file://$<"

.PHONY: $(OUTPUT_DIR)/aws-config.json
$(OUTPUT_DIR)/aws-config.json: aws-config.json $(OUTPUT_DIR)
	sed 's/$${CRYSTAL_VERSION}/$(CRYSTAL_VERSION)/g' "$<" > $@

.PHONY: help
help: ## Show this help
	@echo
	@printf '\033[34mtargets:\033[0m\n'
	@grep -hE '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) |\
		sort |\
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo
	@printf '\033[34mconfiguration variables:\033[0m\n'
	@grep -hE '^[a-zA-Z0-9_-]+ \?=.*?## .*$$' $(MAKEFILE_LIST) |\
		sort |\
		awk 'BEGIN {FS = " \\?=.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo
	@printf '\033[34mrecipes:\033[0m\n'
	@grep -hE '^##.*$$' $(MAKEFILE_LIST) |\
awk 'BEGIN {FS = "## "}; /^## [a-zA-Z_-]/ {printf "  \033[36m%s\033[0m\n", $$2}; /^##  / {printf "  %s\n", $$2}'
