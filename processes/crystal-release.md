# Crystal release process checklist

## Release preparation

1. Start preparing changelog and release post
2. Announce expected release date and time span for feature freeze
   * Feature freeze is about two weeks before release
3. Start feature freeze period
   * Either no merging of features into `master` or split off release branch for backporting bugfixes.
4. Publish release PR draft
   * It should contain the expected date of the release (~two weeks after the PR is issued).
   * It should be populated with updates to `CHANGELOG.md` and `VERSION`.

## Release process

### Source release

1. Finalize the release PR
   * Make sure all changes are mentioned in the changelog
   * Check release date
   * Un-draft the PR
2. Split off release branch (`release/x.y`)
3. Verify Maintenance CI workflow succeeds on the HEAD of the release branch
4. Smoke test with [test-ecosystem](https://github.com/crystal-lang/test-ecosystem)
   * Run [*Test Crystal & Shards Workflow](https://github.com/crystal-lang/test-ecosystem/actions/workflows/test-crystal-shards.yml) with the release branch as `crystal_branch`.
5. Merge the release PR
6. Tag & annotate the commit with the changelog using `<M.m.p>` pattern as {version} (as a pre-release directly in GH?)
7. Publish Github release
   1. Copy the changelog section as description
   1. Binaries are added later
8. Publish docs
   1. Have s3cmd installed and AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY env variables defined
   1. `$ source /Volumes/Secured/secure/manas-aws-key-crystal-dist.sh`
   1. Checkout https://github.com/crystal-lang/crystal-dist
   1. Download `*-docs.tar.gz` from circle-ci artifacts
   1. `$ ./dist.sh push-docs {version} path/to/crystal-{version}-docs.tar.gz`
   1. `$ ./dist.sh update-docs-versions {crystal_working_copy}`
   1. `$ ./dist.sh redirect-docs {version}`

### Binary releases

1. Wait for the release build in circle CI
2. Smoke test with test-ecosystem (again)
3. Attach build artifacts to Github release
   * `crystal-*-darwin-*.tar.gz`
   * `crystal-*-linux-*.tar.gz`
   * `crystal-*.pkg`
   * `crystal-*-docs.tar.gz`
4. Push changes to OBS for building linux packages
   1. Checkout https://github.com/crystal-lang/distribution-scripts and go to [`./packages`](../packages)
   2. Configure build.opensuse.org credentials in environment variables:
      * `export OBS_USER=`
      * `export OBS_PASSWORD=`
   3. Run [`./obs-release.sh $VERSION`](../packages/obs-release.sh)
      * Uses the docker image `crystallang/osc` to run the CLI client for OBS.
      * The script creates a branch in you home project, updates the version and pushes it back to OBS.
      * You can also run the commands from that file manually and check build locally with
         * `osc build xUbuntu_20.04 x86_64`
         * `osc build Fedora_Rawhide x86_64`
   4. Now OBS builds the packages. It’s best to follow the build status in the browser:
      1. `open https://build.opensuse.org/project/show/home:$OBS_USER:branches:devel:langauges:crystal/crystal`
      1. Wait for all package build jobs to finish and succeed
   5. Verify package installation
      * `OBS_PROJECT=home:$OBS_USER:branches:devel:languages:crystal bats test`
   6. When everything is green, create a submit request against the original package (*Submit package* link in the menu bar on the package in your branch)
5. Build and publish docker images
   1. Checkout https://github.com/crystal-lang/crystal-dist
   2. `$ ./dist.sh build-docker {version}`
   3. `$ ./dist.sh push-docker {version}`
   4. Manually push the `crystallang/crystal:{version}` image as `crystallang/crystal:latest`
      * `$ docker tag crystallang/crystal:{version} crystallang/crystal:latest`
      * `$ docker push crystallang/crystal:latest`
   5. Manually build and push alpine images
      * Go to distribution-scripts/docker
      * `$ make clean alpine DOCKER_REPOSITORY=crystallang/crystal DOCKER_TAG={version} CRYSTAL_VERSION={version} CRYSTAL_TARGZ=~/Downloads/crystal-{version}-1-linux-x86_64.tar.gz`
      * `$ docker push crystallang/crystal:{version}-alpine`
      * `$ docker push crystallang/crystal:{version}-alpine-build`
      * `$ docker tag crystallang/crystal:{version}-alpine crystallang/crystal:latest-alpine`
      * `$ docker push crystallang/crystal:latest-alpine`
6. Publish snap package
   1. You need to logged in via `$ snapcraft login`
   1. Recent tagged release is published directly to edge channel. The CI logs the snap revision number. Otherwise the .snap file is in the artifacts.
   1. Check the current status to find the revision of the tagged release otherwise:
   1. `$ snapcraft status crystal`
   1. `$ snapcraft release crystal <revision-number> beta`
   1. `$ snapcraft release crystal <revision-number> stable`
7. Submit a PR to update the homebrew formula in https://github.com/Homebrew/homebrew-core/blob/master/Formula/crystal.rb .
   1. Update the previous and new version (with their respective hashes).
   1. Try locally `$ brew install --build-from-source <source of formula>`
   1. Create PR

### Release announcements
14. Update crystal-website
    1. Post a release notes in the website
    1. Update information of `latest_release` in https://github.com/crystal-lang/crystal-website/blob/master/_config.yml
    1. Update link to blog in https://github.com/crystal-lang/crystal-website/blob/5905e5644fcb4863976d0ca69856edbd74091370/index.html#L26
15. Post announcement in https://forum.crystal-lang.org/c/news/official
16. Tweet about the release
17. Post in Reddit

## Post-release
1. Update crystal `master` branch to use released version
   * Edit PREVIOUS_CRYSTAL_BASE_URL in `.circleci/config.yml`
   * Edit DOCKER_TEST_PREFIX in `bin/ci`
   * Edit `prepare_build` on_osx download package and folder
   * Edit ` .github/workflows/win.yml` to point to docker image
   * Edit `shell.nix` `latestCrystalBinary` using  `nix-prefetch-url --unpack <url>`
2. Increment VERSION file to the next minor and -dev suffix
3. Perform uncomment/todos left in the repo
4. Update carc.in / play.crystal-lang.org (by jhass)
    Note: This is done after Arch repos are updated

## Observable Helper

Build changelog lines
https://observablehq.com/d/035be530d554ccdf

Check commit history
https://observablehq.com/d/4937e5db876fe1d4
