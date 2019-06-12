.PHONY: all
all: snap/snapcraft.yaml
	snapcraft

.PHONY: snap/snapcraft.yaml
snap/snapcraft.yaml:
	sed 's/$${CRYSTAL_RELEASE_LINUX64_TARGZ}/$(subst /,\/,$(CRYSTAL_RELEASE_LINUX64_TARGZ))/; s/$${SNAP_GRADE}/$(SNAP_GRADE)/' snap/local/snapcraft.yaml.tpl > snap/snapcraft.yaml

clean:
	rm snap/snapcraft.yaml
