# Shards release process checklist

1. Submit a Release PR
   * Should contain updates to CHANGELOG, VERSION, shard.yml
   * Should contain updates to the man files with the release date
    `$ make clean docs SOURCE_DATE_EPOCH=$(gdate -d "YYYY-MM-DD" +"%s")` if it’s done ahead of time
2. Merge the Changelog PR
3. Tag & annotate the commit with the changelog using `v<M.m.p>` pattern as {version}
   * `git tag -s vX.X.X`
   * `git push --tags`
4. Build Github release
   * Copy the changelog as release notes in the tag
5. Update distribution-scripts
   * [linux/Makefile](../linux/Makefile)
   * [omnibus/config/software/shards.rb](../omnibus/config/software/shards.rb)
6. Submit a PR to update the homebrew formula in https://github.com/Homebrew/homebrew-core/blob/master/Formula/crystal.rb . Or do it on Crystal release.
