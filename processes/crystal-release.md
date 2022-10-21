# Crystal release process checklist

Add an issue `Crystal release X.Y.Z` in https://github.com/crystal-lang/distribution-scripts/issues with a copy of this document. In this way it's easy to track the progress of the release (*Helper: [`scripts/prepare-crystal-release.sh`](./scripts/prepare-crystal-release.sh)*)

## Release preparation

1. [ ] (minor) Announce expected release date and time span for feature freeze
   * (minor) Feature freeze is about two weeks before release
   * (minor) Set date on milestone
2. [ ] Prepare the changelog entry: [`crystal:scripts/github-changelog.cr`](https://github.com/crystal-lang/crystal/blob/master/scripts/github-changelog.cr)
   * Ensure that all merged PRs are added to the milestone (check [`is:pr is:merged sort:updated-desc no:milestone`](https://github.com/crystal-lang/crystal/pulls?q=is%3Apr+is%3Amerged+sort%3Aupdated-desc+no%3Amilestone)).
   * Ensure that all milestoned PRs are properly labelled (check [`is:pr is:merged sort:updated-desc no:label milestone:${VERSION}`](https://github.com/crystal-lang/crystal/pulls?q=is%3Apr+is%3Amerged+sort%3Aupdated-desc+milestone%3A${VERSION}+no%3Alabel)).
3. [ ] Start preparing release notes
3. [ ] (minor) Start feature freeze period
   * (minor) Either no merging of features into `master` or split off release branch for backporting bugfixes.
4. [ ] Publish release PR draft
   * (minor) It should contain the expected date of the release.
   * It should be populated with updates to `CHANGELOG.md` and `VERSION`.
5. [ ] (minor) Ensure documentation for language and compiler changes and other relevant changes is up to date.
   * (minor) [Crystal Book](https://github.com/crystal-lang/crystal-book/)
      * (minor) Update language specification
      * (minor) Update compiler manual
      * (minor) Add or update guides / tutorials?
6. [ ] Ensure that [test-ecosystem](https://github.com/crystal-lang/test-ecosystem) functions and succeeeds on master
   * Run [*Test Crystal & Shards Workflow*](https://github.com/crystal-lang/test-ecosystem/actions/workflows/test-crystal-shards.yml)

## Release process

### Source release


1. [ ] Finalize the release PR
   * Make sure all changes are mentioned in the changelog
   * Check release date
   * Un-draft the PR
2. [ ] (minor) Split off release branch (`release/x.y`)
3. [ ] Verify Maintenance CI workflow succeeds on the HEAD of the release branch
4. [ ] Smoke test with [test-ecosystem](https://github.com/crystal-lang/test-ecosystem)
   * Run [*Test Crystal & Shards Workflow*](https://github.com/crystal-lang/test-ecosystem/actions/workflows/test-crystal-shards.yml) with the release branch as `crystal_branch`.
5. [ ] Merge the release PR
6. Make the release and publish it on GitHub: [`scripts/make-crystal-release.sh`](https://github.com/crystal-lang/distribution-scripts/blob/master/processes/scripts/make-crystal-release.sh) (run from `crystallang/crystal@master` work tree). This performs these steps:
   1. Tag & annotate the commit with the changelog using `<M.m.p>` pattern as version
     * `git tag -s -a -m $VERSION $VERSION`
     * `git push --tags`
   2. Publish Github release (https://github.com/crystal-lang/crystal/releases/new)
      * Copy the changelog section as description
      * Binaries are added later
8. [ ] Close milestone (https://github.com/crystal-lang/crystal/milestones)
9. [ ] Wait for the release build in circle CI (https://app.circleci.com/pipelines/github/crystal-lang/crystal)

### Binary releases

3. Publish build artifacts from CircleCI and GitHub Actions to GitHub release
   * [ ] Upload build artifacts from CircleCI: [`scripts/publish-crystal-packages-on-github.sh`](https://github.com/crystal-lang/distribution-scripts/blob/master/processes/scripts/publish-crystal-packages-on-github.sh)
      * `crystal-*-darwin-*.tar.gz`
      * `crystal-*-linux-*.tar.gz`
      * `crystal-*.pkg`
      * `crystal-*-docs.tar.gz`
   * [ ] Upload build artifacts from GHA (Windows):
      * `crystal.zip` -> `crystal-$VERSION-windows-x86_64-msvc-unsupported.zip`
4. [ ] Push changes to OBS for building linux packages
   1. Checkout https://github.com/crystal-lang/distribution-scripts and go to [`./packages`](../packages)
   2. Configure build.opensuse.org credentials in environment variables:
      * `export OBS_USER=`
      * `export OBS_PASSWORD=`
   3. Update the `crystal` package: [`./obs-release.sh devel:languages:crystal crystal $VERSION`](../packages/obs-release.sh)
      * Uses the docker image `crystallang/osc` to run the CLI client for OBS.
      * The script creates a branch in you home project, updates the version and pushes it back to OBS.
      * You can also run the commands from that file manually and check build locally with
         * `osc build xUbuntu_20.04 x86_64`
         * `osc build Fedora_Rawhide x86_64`
   4. (minor) Create the `crystal${VERSION%.*}` package: [`./obs-new-minor.sh devel:languages:crystal crystal${VERSION%.*} $VERSION crystal${OLD_VERSION%.*}`](../packages/obs-new-minor.sh)
   4. (patch) Update the `crystal${VERSION%.*}` package: [`./obs-release.sh devel:languages:crystal crystal${VERSION%.*} $VERSION`](../packages/obs-release.sh)
   5. Now OBS builds the packages. It’s best to follow the build status in the browser:
      1. `open https://build.opensuse.org/project/show/home:$OBS_USER:branches:devel:langauges:crystal/crystal`
      1. Wait for all package build jobs to finish and succeed
   6. When everything is green, create a submit request against the original packages (*Submit package* link in the menu bar on the package in your branch)
   7. Verify package installation
      * `OBS_PROJECT=devel:languages:crystal bats test`
5. [ ] Tag `latest` docker images
   * Versioned docker images have been pushed to dockerhub.
   * Now just assign the `latest` tags:
   * `./docker/apply-latest-tags.sh ${VERSION}`
6. [ ] Publish snap package
   1. You need to logged in via `$ snapcraft login`
   1. Recent tagged release is published directly to edge channel. The CI logs the snap revision number. Otherwise the .snap file is in the artifacts.
   1. Check the current status to find the revision of the tagged release otherwise:
   1. `snapcraft status crystal`
   1. `snapcraft release crystal <revision-number> beta`
   1. `snapcraft release crystal <revision-number> stable`
7. [ ] Submit a PR to update the homebrew formula in https://github.com/Homebrew/homebrew-core/blob/master/Formula/crystal.rb .
   1. Update the previous and new version (with their respective hashes).
   1. Try locally `brew install --build-from-source <source of formula>`
   1. Create PR

### Publish documentation for the release

1. [ ] Publish API docs
   1. Have `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` env variables defined
      * Keys can be generated at https://console.aws.amazon.com/iam/home#/security_credentials (contact a Manas admin if you don't have access).
   2. Run `make -C docs publish_docs CRYSTAL_VERSION=${VERSION}` to publish docs to `api/${VERSION}`
   3. Run `make -C docs dist-redirect_latest CRYSTAL_VERSION=${VERSION}` to apply redirect from `api/latest` to `api/${VERSION}`
2. [ ] (minor) Publish Crystal book
   1. (minor) Create `release/${VERSION%.*}` branch (deployment happens automatically in GHA)
   2. (minor) Change default branch to `release/${VERSION%.*}`
   3. (minor) Verify that deployment was successfull

### Release announcements
1. [ ] Publish release notes on the website
2. [ ] Post announcement in https://forum.crystal-lang.org/c/news/official
3. [ ] Tweet about the release
4. [ ] Post in Reddit
5. [ ] Update https://github.com/crystal-lang/crystal-book/blob/master/crystal-version.txt
6. [ ] (minor) Post the release in https://opencollective.com/crystal-lang

## Post-release
1. [ ] Update crystal `master` branch to use released version: [`crystal:scripts/release-update.sh`](https://github.com/crystal-lang/crystal/blob/master/scripts/release-update.sh)
   * Edit PREVIOUS_CRYSTAL_BASE_URL in `.circleci/config.yml`
   * Edit DOCKER_TEST_PREFIX in `bin/ci`
   * Edit `prepare_build` on_osx download package and folder
   * Edit ` .github/workflows/*.yml` to point to docker image
   * Edit `shell.nix` `latestCrystalBinary` using  `nix-prefetch-url --unpack <url>`
2. [ ] (minor) Increment VERSION file to the next minor and -dev suffix
3. [ ] (minor) Perform uncomment/todos left in the repo
4. [ ] Update default base version in test-ecosystem: [`test-ecosystem:scripts/release-update.sh`](https://github.com/crystal-lang/test-ecosystem/blob/master/scripts/release-update.sh)
