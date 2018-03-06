# Recipes for this Makefile

## Build everything
##   $ make

CRYSTAL_VERSION ?=                 ## How the binaries should be branded
CRYSTAL_SHA1 ?= $(CRYSTAL_VERSION) ## Git tag/branch/sha1 to checkout and build source
PACKAGE_ITERATION ?= 1             ## The package iteration

PREVIOUS_CRYSTAL_RELEASE_DARWIN_TARGZ ?= ## url to crystal-{version}-{package}-darwin-x86_64.tar.gz

OUTPUT_DIR = build

# mimics the tgz_package.rb version mangling
DARWIN_PREFIX = crystal-$(subst /,-,$(CRYSTAL_VERSION))-$(PACKAGE_ITERATION)
DARWIN_NAME = $(DARWIN_PREFIX)-darwin-x86_64.tar.gz
DARWIN_PKG_NAME = $(DARWIN_PREFIX).pkg

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
darwin-previous: $(CURDIR)/../omnibus/crystal-darwin-x86_64 ## download previous crystal darwin release

$(CURDIR)/../omnibus/crystal-darwin-x86_64:
	curl -L -o /tmp/crystal-darwin-x86_64.tar.gz $(PREVIOUS_CRYSTAL_RELEASE_DARWIN_TARGZ) \
	&& tar xfz /tmp/crystal-darwin-x86_64.tar.gz -O "crystal-*/embedded/bin/crystal" > $(CURDIR)/../omnibus/crystal-darwin-x86_64 \
	&& rm /tmp/crystal-darwin-x86_64.tar.gz \
	&& chmod +x $(CURDIR)/../omnibus/crystal-darwin-x86_64

$(OUTPUT_DIR)/$(DARWIN_NAME) $(OUTPUT_DIR)/$(DARWIN_PKG_NAME): ## Build omnibus crystal project
	mkdir -p $(OUTPUT_DIR) \
	&& cd ../omnibus \
	&& bundle exec omnibus clean crystal shards \
  && CRYSTAL_VERSION=$(CRYSTAL_VERSION) PACKAGE_ITERATION=$(PACKAGE_ITERATION) CRYSTAL_SHA1=$(CRYSTAL_SHA1) bundle exec omnibus build crystal \
  && cp ./pkg/$(DARWIN_NAME) ./pkg/$(DARWIN_PKG_NAME) $(CURDIR)/$(OUTPUT_DIR)/

.PHONY: clean
clean: ## Clean up build directory
	rm -Rf $(OUTPUT_DIR)
	rm -Rf $(CURDIR)/../omnibus/pkg/crystal-*
	rm -Rf $(CURDIR)/../omnibus/pkg/version-*
	rm -Rf $(CURDIR)/../omnibus/crystal-darwin-x86_64
	rm -Rf /var/cache/omnibus/*
	rm -Rf /opt/crystal/*
