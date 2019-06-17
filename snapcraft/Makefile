OUTPUT_DIR = build

.PHONY: all
all: snap/snapcraft.yaml
	mkdir -p $(OUTPUT_DIR)
	snapcraft
	mv *.snap $(OUTPUT_DIR)

.PHONY: snap/snapcraft.yaml
snap/snapcraft.yaml:
	sed 's/$${CRYSTAL_RELEASE_LINUX64_TARGZ}/$(subst /,\/,$(CRYSTAL_RELEASE_LINUX64_TARGZ))/; s/$${SNAP_GRADE}/$(SNAP_GRADE)/' snap/local/snapcraft.yaml.tpl > snap/snapcraft.yaml

clean:
	rm snap/snapcraft.yaml
	rm -Rf $(OUTPUT_DIR)
