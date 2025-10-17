# Crystal release process checklist

Add an issue `Crystal release X.Y.Z` in
https://github.com/crystal-lang/distribution-scripts/issues with a copy of this
document. In this way it's easy to track the progress of the release (*Helper:
(`distribttion-scripts`)
[`scripts/prepare-crystal-release.sh`](./scripts/prepare-crystal-release.sh)*)

## Release preparation

1. [ ] (minor) Announce expected release date (${RELEASE_DATE}) and time span for feature freeze (starting on ${FREEZE_PERIOD})
   * (minor) Feature freeze is about two weeks before release
2. Set date on the milestone
3. [ ] Prepare the changelog entry: (`crystal`) [`scripts/update-changelog.cr ${VERSION}`](https://github.com/crystal-lang/crystal/blob/master/scripts/update-changelog.cr)
   * Ensure that all merged PRs are added to the milestone (check [`is:pr is:merged sort:updated-desc no:milestone`](https://github.com/crystal-lang/crystal/pulls?q=is%3Apr+is%3Amerged+sort%3Aupdated-desc+no%3Amilestone+-label%3Astatus%3Areverted+base%3Amaster+merged%3A%3E%3D2023-01-01)).
   * Ensure that all milestoned PRs are properly labelled (check [`is:pr is:merged sort:updated-desc no:label milestone:${VERSION}`](https://github.com/crystal-lang/crystal/pulls?q=is%3Apr+is%3Amerged+sort%3Aupdated-desc+milestone%3A${VERSION}+no%3Alabel)).
4. [ ] Start preparing release notes, publish draft in [`crystal-lang/crystal-website`](https://github.com/crystal-lang/crystal-website/)
5. [ ] (minor) Start feature freeze period (on ${FREEZE_PERIOD})
   * (minor) Either no merging of features into `master` or split off release branch for backporting bugfixes.
6. [ ] Publish release PR draft
   * (minor) It should contain the expected date of the release.
   * It should be populated with updates to `CHANGELOG.md`, `src/VERSION` and the version in `shard.yml`.
7. [ ] (minor) Ensure documentation for language and compiler changes and other relevant changes is up to date.
   * (minor) [Crystal Book](https://github.com/crystal-lang/crystal-book/)
      * (minor) Update language specification
      * (minor) Update compiler manual
      * (minor) Add or update guides / tutorials?
8. [ ] (minor) Look for library updates, check and document compatibility at https://crystal-lang.org/reference/man/required_libraries.html and in lib bindings
9. [ ] Ensure that [test-ecosystem](https://github.com/crystal-lang/test-ecosystem) functions and succeeds on master
   * Run [*CI Workflow*](https://github.com/crystal-lang/test-ecosystem/actions/workflows/ci.yml) on `master` (uses nightly build)

## Release process (on ${RELEASE_DATE})

### Source release

1. [ ] Finalize the changelog PR
   * Make sure all changes are mentioned in the changelog
   * Check release date
   * Un-draft the PR
2. [ ] (minor) Split off release branch `release/${VERSION%.*}` from `master` to trigger Maintenance CI
3. [ ] Verify Maintenance CI workflow succeeds on the HEAD of the release
   branch: https://app.circleci.com/pipelines/github/crystal-lang/crystal?branch=release%2F${VERSION%.*}
4. [ ] Smoke test with [test-ecosystem](https://github.com/crystal-lang/test-ecosystem)
   * Run [*CI Workflow*](https://github.com/crystal-lang/test-ecosystem/actions/workflows/ci.yml) with `crystal=branch:release/{VERSION%.*}`.
5. [ ] Merge the changelog PR
6. [ ] Make the release and publish it on GitHub: (`crystal`) [`../distribution-scripts/processes/scripts/make-crystal-release.sh`](https://github.com/crystal-lang/distribution-scripts/blob/master/processes/scripts/make-crystal-release.sh) (run from `crystallang/crystal@${VERSION}` work tree). This performs these steps:
   1. Tag & annotate the commit with the changelog using `<M.m.p>` pattern as version
     * `git tag -s -a -m ${VERSION} ${VERSION}`
     * `git push --tags`
   2. Publish Github release (https://github.com/crystal-lang/crystal/releases/new)
      * Copy the changelog section as description
      * Binaries are added later
8. [ ] Close milestone (https://github.com/crystal-lang/crystal/milestones)
9. [ ] Wait for the release build in circle CI (https://app.circleci.com/pipelines/github/crystal-lang/crystal)
10. [ ] Fast-forward `release/${VERSION%.*}` to `master@${VERSION}`

### Binary releases

3. Publish build artifacts from CircleCI and GitHub Actions to GitHub release. For `URL_TO_CIRCLECI_ARTIFACT` grab the URL
   of any of the build artifacts in circleCI (doesn't matter which).
   * [ ] Upload build artifacts from CircleCI: (`crystal`) [`../distribution-scripts/processes/scripts/publish-crystal-packages-on-github.sh $URL_TO_CIRCLECI_ARTIFACT`](https://github.com/crystal-lang/distribution-scripts/blob/master/processes/scripts/publish-crystal-packages-on-github.sh) (run from `crystallang/crystal@${VERSION}` work tree)
      * `crystal-*-darwin-*.tar.gz`
      * `crystal-*-linux-*.tar.gz`
      * `crystal-*.pkg`
      * `crystal-*-docs.tar.gz`
   * [ ] Upload build artifacts from GHA (Windows):
      * Windows CI: `crystal.zip` -> `crystal-${VERSION}-windows-x86_64-msvc-unsupported.zip`
      * Windows CI: `crystal-installer.zip` -> unzip -> `crystal-${VERSION}-windows-x86_64-msvc-unsupported.exe`
      * MinGW-w64 CI: `x86_64-mingw-w64-crystal.zip` -> `crystal-${VERSION}-windows-x86_64-gnu-unsupported.zip`
      * MinGW-w64 CI: `aarch64-mingw-w64-crystal.zip` -> `crystal-${VERSION}-windows-aarch64-gnu-unsupported.zip`
2. [ ] Publish the GitHub release
3. [ ] Push changes to OBS for building linux packages
   1. Checkout https://github.com/crystal-lang/distribution-scripts and go to [`./packages`](../packages)
   2. Configure build.opensuse.org credentials in environment variables:
      * `export OBS_USER=`
      * `export OBS_PASSWORD=`
   3. (minor) Update the `crystal` package: (`distribution-scripts`) [`./obs-release.sh devel:languages:crystal crystal ${VERSION}`](../packages/obs-release.sh)
      * (minor) Uses the docker image `crystallang/osc` to run the CLI client for OBS.
      * (minor) The script creates a branch in you home project, updates the version and pushes it back to OBS.
      * (minor) You can also run the commands from that file manually and check build locally with
         * (minor) `osc build xUbuntu_20.04 x86_64`
         * (minor) `osc build Fedora_Rawhide x86_64`
   4. (minor) Create the `crystal${VERSION%.*}` package: (`distribution-scripts`) [`./obs-new-minor.sh devel:languages:crystal crystal${VERSION%.*} ${VERSION} crystal${OLD_VERSION%.*}`](../packages/obs-new-minor.sh)
   5. (patch) Update the `crystal${VERSION%.*}` package: (`distribution-scripts`) [`./obs-release.sh devel:languages:crystal crystal${VERSION%.*} ${VERSION}`](../packages/obs-release.sh)
   6. Now OBS builds the packages. It’s best to follow the build status in the browser:
      1. `open https://build.opensuse.org/package/show/home:$OBS_USER:branches:devel:languages:crystal/crystal`
      1. `open https://build.opensuse.org/package/show/home:$OBS_USER:branches:devel:languages:crystal/crystal${VERSION%.*}`
      2. Wait for all package build jobs to finish and succeed
   7. When everything is green, create a submit request against the original
      packages: *Submit package* link in the page actions (left sidebar) in your branch.
   8. (optional) Verify package installation
      * (`distribution-scripts/packages`) `OBS_PROJECT=devel:languages:crystal bats test`
4. [ ] Tag `latest` docker images
   * Versioned docker images have been pushed to Docker Hub.
   * Now just assign the `latest` tags:
   *  (`distribution-scripts`) `./docker/apply-latest-tags.sh ${VERSION}`
5. [ ] Publish snap package
   - On https://snapcraft.io/crystal/releases promote the `latest/edge` release to `latest/beta` and then `latest/stable`
6. [ ] Check PR for homebrew: https://github.com/Homebrew/homebrew-core/pulls?q=is%3Apr+crystal+sort%3Aupdated-desc
   * It should've been automatically created

### Publish documentation for the release

1. [ ] Publish API docs
   1. Have `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` env variables defined
      * Keys can be generated at https://console.aws.amazon.com/iam/home#/security_credentials (contact a Manas admin if you don't have access).
   2. Run (`distribution-scripts`) `make -C docs publish_docs release_latest_docs CRYSTAL_VERSION=${VERSION}` to publish docs to `api/${VERSION}`, apply redirect from `api/latest` to `api/${VERSION}` and set the 404 error page
   3. Update API docs' 404 page to add `<base href="/api/${VERSION}/" />` in the `<head>`
2. [ ] (minor) Publish Crystal book
   1. (minor) Make sure `release/${OLD_VERSION%.*}` branch is merged into `master` (if not, create a PR; **it needs to be merged as a merge commit**)
   2. (minor) Create `release/${VERSION%.*}` branch and push it to `crystal-lang/crystal-book` (deployment happens automatically in GHA)
   3. (minor) Verify that deployment was successful

### Release announcements

1. [ ] Publish release notes on the website
   - Make sure all links to API docs point to `/api/${VERSION}/`
   - Insert number of changes and contributers
2. [ ] Wait for website to build, then visit the release notes page. This should
  create a thread for comments on the forum. Publish that topic
  ("List topic" in the wrench icon) and add tag `release`.
1. [ ] Announce on social media accounts (via Buffer; credentials are in Passbolt) and pin release posts
3. [ ] (minor) Have the project manager post the release in https://opencollective.com/crystal-lang

## Post-release
1. [ ] Create a pull request to update `master` branch to use released version:
   (`crystal`) [`scripts/release-update.sh
   ${VERSION}`](https://github.com/crystal-lang/crystal/blob/master/scripts/release-update.sh)
   * Edit PREVIOUS_CRYSTAL_BASE_URL in `.circleci/config.yml`
   * Edit DOCKER_TEST_PREFIX in `bin/ci`
   * Edit `prepare_build` on_osx download package and folder
   * Edit ` .github/workflows/*.yml` to point to docker image
   * Edit `shell.nix` `latestCrystalBinary` using  `nix-prefetch-url --unpack <url>`
   * Branch: `infra/release-update`. Commit message: `Update previous Crystal release ${VERSION}`
2. [ ] (minor) Increment `src/VERSION` and version in `shard.yml` to the next minor plus `-dev` suffix
3. [ ] (minor) Perform uncomment/todos left in the repo
4. [ ] Merge `release/${VERSION%.*}` branch into `master` (if the two have diverged)
   - This needs to be a *merge commit*. Those are disabled in the GitHub UI.
   - Create branch and PR:
     ```sh
     git fetch upstream release/${VERSION%.*} master
     git switch -c merge/${VERSION} upstream/master
     git merge upstream/release/${VERSION%.*}
     # resolve conflicts
     git commit -m 'Merge `release/${VERSION%.*}` into master'
     git log --graph --decorate --pretty=oneline --abbrev-commit
     git push -u upstream merge/${VERSION}
     gh pr create --title 'Merge `release/${VERSION%.*}` into master' --label 'topic:infrastructure'
     ```
   - Merge PR **locally**:
     ```sh
     git switch master
     git merge --ff-only merge/${VERSION}
     # double check history
     git log --graph --decorate --pretty=oneline --abbrev-commit
     git push
     ```
   - GitHub branch protection rules normally prevent direct pushes to
     `master`. This needs to be deactivated for this purpose, which can be on a
     per-user basis.
   - In case master has diverged, `--ff-only` merge will fail. Then you can
     first rebase `merge/${VERSION}` on current master with `git rebase master --rebase-merges`.
