# Packages on Open Build Service

[OBS](https://openbuildservice.org) builds the .deb and .rpm repositories and publishes them in their repositories.

We're using separate OBS projects for the different release strategies:

* Stable releases: https://build.opensuse.org/package/show/devel:languages:crystal/crystal
* Nightly releases: https://build.opensuse.org/package/show/devel:languages:crystal:nightly/crystal
* Unstable releases (currently unused): https://build.opensuse.org/package/show/devel:languages:crystal:unstable/crystal

Each project can contain multiple packages. Currently, there is only a `crystal` package in each project.

The tarballs with the generic linux binaries are statically linked and should work on any linux distribution.
We use them as a basis for all packages. OBS does not rebuild the compiler. It just packages them.

## Nightly releases

Nightlies are uploaded automatically in the `push_obs_nightly` job on circle ci.
The ci job authenticates as crystalbot. This user account has only access to the nightly project.

## Stable releases

Stable (and unstable releases) are pushed manually to the OBS project.

In the future, we could even consider automating this, but it's fairly easy to do and just another point on the release check list.

## Publishing a new release

To publish a new release, we need to update the source files and version information in the OBS project.

While this can be done via the web UI, it's far easier using the command line client [osc](https://openbuildservice.org/help/manuals/obs-user-guide/cha.obs.osc.html).

### Setup OSC

A dockerfile provided at https://github.com/crystal-lang/osc-docker ([`crystallang/osc`](https://hub.docker.com/r/crystallang/osc) on dockerhub) contains all the necessary utilities for running osc.

NOTE: While there are osc packages for other distributions, they are likely broken and it's strongly advised to run it on openSUSE.

To avoid manual sign in, you can configure OBS credentials in `~/.oscrc`. See [`obs-setup.sh`](./obs-setup.sh) for the template.
We use our personal SUSE user accounts to authenticate with build.opensuse.org. Crystalbot is only responsible for pushing nightly updates.

NOTE: Source code management in OBS packages is based on subversion. OSC is basically a frontend with reduced functionality (but more OBS-specific features).

### Update package

With osc, we check out the package configuration, update the version information and source tarballs, and finally push it back to OBS.

The entire round trip is implemented in [`obs-push.sh`](./obs-push.sh). This script is targeted for the automatic nightly workflow. For manually published builds it's advisable to run the commands separately.

```terminal-session
# Checkout OBS project
osc checkout "$PROJECT" "$PACKAGE"
cd "$PROJECT/$PACKAGE"

# Copy build artifacts and update versions

# Update changes file
osc vc

# Check changes
osc diff

# Commit changes and push to OBS
osc commit
```

NOTE: The `osc commit` command directly pushes to the remote repository. This is different from git, where a commit is only local and you need to explicitly push.

Before committing the changes, you may use `osc build` for a local test to see if everything works. This uses the default build target, but you can specify a repository name and architecture are arguments (for example `osc build Debian_10 x86_64`).

Alternatively, you can use a branch package to run a test build on OBS.

### Test build

To test if a build succeeds, we can use a branching strategy. In contrast to git, where you would create a new branch in the repository, in OBS you branch the entire project. The branch project is created in your personal namespace (`home:$USERNAME:branches:$PROJECT`).

After creating the branch package, you check that out locally, apply the changes and commit (see [*Update package*](#Update package)). OBS then builds the packages in your branch project. If everything is green, you create a submit request which would pull the changes into the main project (similar to a pull request on GitHub).

See [*Branching a Package* in the OBS Beginner's Guide](https://openbuildservice.org/help/manuals/obs-user-guide/art.obs.bg.html#sec.obsbg.uc.branchprj) for more details on this workflow.
