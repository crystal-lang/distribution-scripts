CRYSTAL_TARBALL =
ARCH =
GRADE =
CHANNEL =

.PHONY: all
all: snapcraft.yaml
	snapcraft pack --build-for=$(ARCH)

.PHONY: snapcraft.yaml
snapcraft.yaml:
	sed 's/$${CRYSTAL_TARBALL}/$(subst /,\/,$(CRYSTAL_TARBALL))/; s/$${SNAP_GRADE}/$(GRADE)/' local/snapcraft.yaml.tpl > $@

.PHONY: push
push:
	for SNAPFILE in *.snap; do\
		sudo -E snapcraft upload --quiet --release=$(CHANNEL) $$SNAPFILE;\
	done

clean:
	snapcraft clean
	rm -f snapcraft.yaml *.snap
