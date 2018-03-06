CRYSTAL_VERSION ?=   ## How the binaries should be branded
CRYSTAL_DEB ?=       ## which crystal.deb file to install in the docker images
DOCKER_TAG ?=        ## How to tag the docker image. a -build will be appended for -build image
DOCKER_REPOSITORY ?= ## Docker hub repository to commit image

OUTPUT_DIR = build
BUILD_ARGS = --build-arg crystal_deb=./tmp/crystal.deb

.PHONY: all
all: $(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION).tar.gz $(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-build.tar.gz

$(CURDIR)/tmp/crystal.deb:
	mkdir -p $(CURDIR)/tmp
	cp $(CRYSTAL_DEB) $(CURDIR)/tmp/crystal.deb

$(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION).tar.gz: $(CURDIR)/tmp/crystal.deb
	mkdir -p $(OUTPUT_DIR)
	docker build $(BUILD_ARGS) --target runtime -t $(DOCKER_REPOSITORY):$(DOCKER_TAG) .
	docker save $(DOCKER_REPOSITORY):$(DOCKER_TAG) | gzip > $(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION).tar.gz

$(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-build.tar.gz: $(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION).tar.gz
	mkdir -p $(OUTPUT_DIR)
	docker build $(BUILD_ARGS) --target build -t $(DOCKER_REPOSITORY):$(DOCKER_TAG)-build .
	docker save $(DOCKER_REPOSITORY):$(DOCKER_TAG)-build | gzip > $(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-build.tar.gz

.PHONY: clean
clean: ## Clean up build directory
	rm -Rf $(OUTPUT_DIR)
	rm -Rf $(CURDIR)/tmp
