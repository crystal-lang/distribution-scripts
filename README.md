# Distribution scripts for Crystal

This repository contains scripts to build distributions of the crystal compiler
ready for release. It is used for building the tarballs and linux packages -
currently only for `x86_64`, but eventually for every well supported platform.

These packages contain `crystal`, `shards`, a copy of the standard library, and
anything else required to make use of crystal.

Each logical platform has it's own sub-directory, containing a `README` with
information on it's own dependencies and it's own information on how to build.
