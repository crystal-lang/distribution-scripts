CRYSTAL_VERSION ?=   ## How the binaries should be branded
CRYSTAL_DEB ?=       ## which crystal.deb file to install in the docker images
DOCKER_TAG ?=        ## How to tag the docker image. a -build will be appended for -build image
DOCKER_REPOSITORY ?= ## Docker hub repository to commit image

OUTPUT_DIR = build
BUILD_ARGS64 = --build-arg crystal_deb=./tmp/crystal.deb --build-arg base_docker_image=ubuntu:bionic
BUILD_ARGS32 = --build-arg crystal_deb=./tmp/crystal.deb --build-arg base_docker_image=i386/ubuntu:bionic

.PHONY: all64
all64: $(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION).tar.gz $(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-build.tar.gz

.PHONY: all32
all32: $(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-i386.tar.gz $(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-i386-build.tar.gz

$(CURDIR)/tmp/crystal.deb:
	mkdir -p $(CURDIR)/tmp
	cp $(CRYSTAL_DEB) $(CURDIR)/tmp/crystal.deb

$(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION).tar.gz: $(CURDIR)/tmp/crystal.deb
	mkdir -p $(OUTPUT_DIR)
	docker build $(BUILD_ARGS64) --target runtime -t $(DOCKER_REPOSITORY):$(DOCKER_TAG) .
	docker save $(DOCKER_REPOSITORY):$(DOCKER_TAG) | gzip > $(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION).tar.gz

$(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-build.tar.gz: $(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION).tar.gz
	mkdir -p $(OUTPUT_DIR)
	docker build $(BUILD_ARGS64) --target build -t $(DOCKER_REPOSITORY):$(DOCKER_TAG)-build .
	docker save $(DOCKER_REPOSITORY):$(DOCKER_TAG)-build | gzip > $(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-build.tar.gz

$(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-i386.tar.gz: $(CURDIR)/tmp/crystal.deb
	mkdir -p $(OUTPUT_DIR)
	docker build $(BUILD_ARGS32) --target runtime -t $(DOCKER_REPOSITORY):$(DOCKER_TAG)-i386 .
	docker save $(DOCKER_REPOSITORY):$(DOCKER_TAG)-i386 | gzip > $(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-i386.tar.gz

$(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-i386-build.tar.gz: $(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-i386.tar.gz
	mkdir -p $(OUTPUT_DIR)
	docker build $(BUILD_ARGS32) --target build -t $(DOCKER_REPOSITORY):$(DOCKER_TAG)-i386-build .
	docker save $(DOCKER_REPOSITORY):$(DOCKER_TAG)-i386-build | gzip > $(OUTPUT_DIR)/docker-$(CRYSTAL_VERSION)-i386-build.tar.gz

.PHONY: clean
clean: ## Clean up build directory
	rm -Rf $(OUTPUT_DIR)
	rm -Rf $(CURDIR)/tmp
