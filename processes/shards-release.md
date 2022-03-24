# Shards release process checklist

Add an issue `Shards release X.Y.Z` in https://github.com/crystal-lang/distribution-scripts/issues with a copy of this document. In this way it's easy to track the progress of the release (*Helper script: [`scripts/prepare-shards-release.sh`](./scripts/prepare-shards-release.sh)*)

## Release preparation

1. [ ] Start preparing changelog and release notes
2. [ ] Publish release PR draft
   * It should be populated with updates to `CHANGELOG.md`, `VERSION`, and `shard.yml`.

## Release process

*Steps 4.-6. are automated via [`scripts/make-shards-release.sh`](https://github.com/crystal-lang/distribution-scripts/blob/master/processes/scripts/make-shards-release.sh)*

1. [ ] Finalize the release PR
   * Make sure all changes are mentioned in the changelog
   * Check release date
   * Build man files with the release date: `$ make clean docs SOURCE_DATE_EPOCH=$(gdate -d "YYYY-MM-DD" +"%s")`
   * Un-draft the PR
2. [ ] (minor) Split off release branch (`release/x.y`)
3. [ ] Smoke test with [test-ecosystem](https://github.com/crystal-lang/test-ecosystem)
   * Run [*Test Crystal & Shards Workflow*](https://github.com/crystal-lang/test-ecosystem/actions/workflows/test-crystal-shards.yml) with the release branch as `shards_branch`.
4. [ ] Merge the release PR
5. [ ] Tag & annotate the commit with the changelog using v`<M.m.p>` pattern as {version}
   * `git tag -s -a -m v$VERSION v$VERSION`
6. [ ] Publish Github release (https://github.com/crystal-lang/shards/releases/new)
   * Copy the changelog section as description
7. [ ] Close milestone (https://github.com/crystal-lang/shards/milestones)

## Post-release

1. [ ] (minor) Increment VERSION file to the next minor and -dev suffix
2. [ ] Update distribution-scripts
   * Edit [linux/Makefile](../linux/Makefile)
   * Edit [omnibus/config/software/shards.rb](../omnibus/config/software/shards.rb)
3. [ ] Update https://github.com/crystal-lang/crystal
   * Edit [`.github/workflows/win.yml`](https://github.com/crystal-lang/crystal/blob/master/.github/workflows/win.yml)
3. [ ] Submit a PR to update the homebrew formula in https://github.com/Homebrew/homebrew-core/blob/master/Formula/crystal.rb . Or do it on Crystal release.
4. [ ] Update default base version in test-ecosystem
6. [ ] (minor) Perform uncomment/todos left in the repo
