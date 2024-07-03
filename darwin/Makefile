# Recipes for this Makefile

## Build everything
##   $ make

CRYSTAL_REPO ?= https://github.com/crystal-lang/crystal## Allow to override the official repo with fork or local
CRYSTAL_VERSION ?=                 ## How the binaries should be branded
CRYSTAL_SHA1 ?= $(CRYSTAL_VERSION) ## Git tag/branch/sha1 to checkout and build source
PACKAGE_ITERATION ?= 1
FORCE_GIT_TAGGED ?= 1              ## Require build to be based on git tag/branch

PREVIOUS_CRYSTAL_RELEASE_DARWIN_TARGZ ?= ## url to crystal-{version}-{package}-darwin-x86_64.tar.gz

OMNIBUS_OPTS ?=                    ## Build arguments for omnibus command line
OUTPUT_DIR = build

# mimics the tgz_package.rb version mangling
DARWIN_ARCH = $(shell uname -m)
DARWIN_PREFIX = crystal-$(CRYSTAL_VERSION)-$(PACKAGE_ITERATION)
DARWIN_NAME = $(DARWIN_PREFIX)-darwin-$(DARWIN_ARCH).tar.gz
DARWIN_PKG_NAME = $(DARWIN_PREFIX).$(DARWIN_ARCH).pkg

.PHONY: all
all: darwin-previous $(OUTPUT_DIR)/$(DARWIN_NAME) $(OUTPUT_DIR)/$(DARWIN_PKG_NAME) ## Build compressed omnibus and distribution packages [default]

.PHONY: help
help: ## Show this help
	@echo
	@printf '\033[34mtargets:\033[0m\n'
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) |\
		sort |\
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo
	@printf '\033[34moptional variables:\033[0m\n'
	@grep -hE '^[a-zA-Z_-]+ \?=.*?## .*$$' $(MAKEFILE_LIST) |\
		sort |\
		awk 'BEGIN {FS = " \\?=.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo
	@printf '\033[34mrecipes:\033[0m\n'
	@grep -hE '^##.*$$' $(MAKEFILE_LIST) |\
awk 'BEGIN {FS = "## "}; /^## [a-zA-Z_-]/ {printf "  \033[36m%s\033[0m\n", $$2}; /^##  / {printf "  %s\n", $$2}'

.PHONY: darwin-previous
darwin-previous: $(CURDIR)/../omnibus/crystal-darwin-x86_64/embedded/bin/crystal ## download previous crystal darwin release

# Once there are prior builds for arm64, this can use DARWIN_ARCH
$(CURDIR)/../omnibus/crystal-darwin-x86_64/embedded/bin/crystal:
	curl -L -o /tmp/crystal-darwin-x86_64.tar.gz $(PREVIOUS_CRYSTAL_RELEASE_DARWIN_TARGZ) \
	&& mkdir -p $(CURDIR)/../omnibus/crystal-darwin-x86_64 \
	&& tar xfz /tmp/crystal-darwin-x86_64.tar.gz -C $(CURDIR)/../omnibus/crystal-darwin-x86_64 --strip-components=1 \
	&& rm /tmp/crystal-darwin-x86_64.tar.gz \
	&& chmod +x $(CURDIR)/../omnibus/crystal-darwin-x86_64/embedded/bin/crystal

$(OUTPUT_DIR)/$(DARWIN_NAME) $(OUTPUT_DIR)/$(DARWIN_PKG_NAME): ## Build omnibus crystal project
ifeq ($(FORCE_GIT_TAGGED), 0)
	rm -Rf $(CURDIR)/tmp && mkdir -p $(CURDIR)/tmp && cd $(CURDIR)/tmp \
	&& git clone "$(CRYSTAL_REPO)" \
	&& cd crystal \
	&& git checkout $(CRYSTAL_SHA1) \
	&& git checkout -b $(CRYSTAL_VERSION)
endif

	mkdir -p $(OUTPUT_DIR) \
	&& cd ../omnibus \
	&& if [ "$(FORCE_GIT_TAGGED)" -eq "0" ]; then export CRYSTAL_SRC=$(CURDIR)/tmp/crystal/.git; fi \
	&& export MACOSX_DEPLOYMENT_TARGET=11.0 \
	&& export SDKROOT=$(shell xcrun --sdk macosx --show-sdk-path) \
	&& bundle exec omnibus clean crystal shards \
	&& bundle exec omnibus build crystal $(OMNIBUS_OPTS) \
	&& cp ./pkg/$(DARWIN_NAME) $(CURDIR)/$(OUTPUT_DIR)/$(subst x86_64,universal,$(DARWIN_NAME)) \
	&& cp ./pkg/$(DARWIN_PKG_NAME) $(CURDIR)/$(OUTPUT_DIR)/$(subst x86_64,universal,$(DARWIN_PKG_NAME))

.PHONY: clean
clean: ## Clean up build directory
	rm -Rf $(OUTPUT_DIR)
	rm -Rf $(CURDIR)/tmp
	rm -Rf $(CURDIR)/../omnibus/pkg/crystal-*
	rm -Rf $(CURDIR)/../omnibus/pkg/version-*
	rm -Rf $(CURDIR)/../omnibus/crystal-darwin-*
	rm -Rf /var/cache/omnibus/*
	rm -Rf /opt/crystal/*
