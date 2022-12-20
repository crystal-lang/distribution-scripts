OUTPUT_DIR = build

ifeq ($(arch),x86_64)
  SNAP_BUILD_FOR = --build-for amd64
else ifeq ($(arch),aarch64)
  SNAP_BUILD_FOR = --build-for arm64
else
  $(error Expected arch to be one of 'x86_64', or 'aarch64', got: $(arch))
endif

.PHONY: all
all: snap/snapcraft.yaml
	mkdir -p $(OUTPUT_DIR)
	snapcraft $(SNAP_BUILD_FOR)
	mv *.snap $(OUTPUT_DIR)

.PHONY: snap/snapcraft.yaml
snap/snapcraft.yaml:
	sed 's/$${CRYSTAL_RELEASE_LINUX64_TARGZ}/$(subst /,\/,$(CRYSTAL_RELEASE_LINUX64_TARGZ))/; s/$${SNAP_GRADE}/$(SNAP_GRADE)/' snap/local/snapcraft.yaml.tpl > $@

clean:
	rm snap/snapcraft.yaml
	rm -Rf $(OUTPUT_DIR)
