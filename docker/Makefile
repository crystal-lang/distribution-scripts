# Recipes for this Makefile

## Build all docker images
##   $ make VERSION=1.18.2
## Build specific docker images
##   $ make build-ubuntu VERSION=1.18.2
##   $ make build-alpine-build VERSION=1.18.2
##
## Push all docker images to registry
##   $ make push VERSION=1.18.2
## Push a specific docker image to registry
##   $ make push-ubuntu VERSION=1.18.2
##   $ make push-alpine-build VERSION=1.18.2
##
## Run smoke tests
##   $ make smoke-all
##   $ make smoke-ubuntu-build
##   $ make smoke-alpine-runtime

VERSION ?= ## Version name of the source tarballs
TARBALLS ?= ./tarballs## Path to folder which contains the Crystal tarballs to install in docker images.

BUILD_CONTEXT := ./build-context
TAG := crystallang/crystal:$(VERSION)## Base tag of the docker image. Classifiers like `-ubuntu` and `-build` will be appended.

PLATFORM := linux/amd64,linux/arm64
comma:=,
PLATFORM_TARBALLS := $(patsubst linux/%,$(BUILD_CONTEXT)/crystal-%.tar.gz,$(subst $(comma), ,$(PLATFORM)))

.PHONY: all
all: ## Build all images
all: build-ubuntu
all: build-ubuntu-build
all: build-alpine
all: build-alpine-build

.PHONY: push
push: ## Push all images to the registry
push: push-ubuntu
push: push-ubuntu-build
push: push-alpine
push: push-alpine-build

push-%:
	docker push $(TAG)$(subst -ubuntu,,-$*)

$(BUILD_CONTEXT)/crystal-amd64.tar.gz: $(TARBALLS)/crystal-$(VERSION)-1-linux-x86_64.tar.gz | $(BUILD_CONTEXT)
	cp $< $@

$(BUILD_CONTEXT)/crystal-arm64.tar.gz: $(TARBALLS)/crystal-$(VERSION)-1-linux-aarch64.tar.gz | $(BUILD_CONTEXT)
	cp $< $@

$(BUILD_CONTEXT):
	mkdir -p $@

.PHONY: build-alpine
build-alpine: alpine.Dockerfile $(PLATFORM_TARBALLS)
	docker buildx build --platform $(PLATFORM) --file alpine.Dockerfile -t $(TAG)-alpine --target runtime $(BUILD_CONTEXT)

.PHONY: build-alpine-build
build-alpine-build: alpine.Dockerfile $(PLATFORM_TARBALLS)
	docker buildx build --platform $(PLATFORM) --file alpine.Dockerfile -t $(TAG)-alpine-build --target build $(BUILD_CONTEXT)

.PHONY: build-ubuntu
build-ubuntu: ubuntu.Dockerfile $(PLATFORM_TARBALLS)
	docker buildx build --platform $(PLATFORM) --file ubuntu.Dockerfile -t $(TAG) --target runtime $(BUILD_CONTEXT)

.PHONY: build-ubuntu-build
build-ubuntu-build: ubuntu.Dockerfile $(PLATFORM_TARBALLS)
	docker buildx build --platform $(PLATFORM) --file ubuntu.Dockerfile -t $(TAG)-build --target build $(BUILD_CONTEXT)

alpine-84codes: ## Build and push docker build images based on the base images from 84codes
	docker buildx build --build-arg crystal_version=$(VERSION) -f alpine-84codes.Dockerfile --platform linux/amd64,linux/arm64 --tag $(TAG)-alpine-84codes-build --push .

ubuntu-84codes: ## Build and push docker build images based on the base images from 84codes
	docker buildx build --build-arg crystal_version=$(VERSION) -f ubuntu-84codes.Dockerfile --platform linux/amd64,linux/arm64 --tag $(TAG)-ubuntu-84codes-build --push .

.PHONY: smoke-all
smoke-all: ## Run smoke tests on all docker images
smoke-all: smoke-alpine
smoke-all: smoke-alpine-build
smoke-all: smoke-ubuntu
smoke-all: smoke-ubuntu-build

.PHONY: smoke-%
smoke-%: # Run smoke tests on docker images
	docker run --rm -v $(CURDIR)/smoke.sh:/smoke.sh -e VERSION=$(VERSION) $(TAG)$(subst -ubuntu,,-$*) /smoke.sh $*

.PHONY: clean
clean: ## Clean up build context
	rm -Rf $(BUILD_CONTEXT)

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
