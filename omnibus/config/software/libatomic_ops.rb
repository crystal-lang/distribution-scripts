name "libatomic_ops"
default_version "7.6.10"
skip_transitive_dependency_licensing true

source :url => "https://github.com/ivmai/libatomic_ops/releases/download/v#{version}/libatomic_ops-#{version}.tar.gz"

version "7.4.10" do
  source md5: "47dcc36e1f77ab0efdee5d99888b3ffe"
end

version "7.6.6" do
  source md5: "4514d85d14e21af05d59877c9ded5abc"
end

version "7.6.10" do
  source md5: "90a78a84d9c28ce11f331c25289bfbd0"
end

relative_path "libatomic_ops-#{version}"

env = with_standard_compiler_flags
sysroot = "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk"
env["CFLAGS"] << " -fPIC -arch arm64 -arch x86_64 -isysroot #{sysroot} -isystem #{sysroot} "
env["CPPFLAGS"] = env["CPPFLAGS"].gsub("-arch arm64 -arch x86_64", "")

build do
  command "./configure" \
          " --disable-dependency-tracking" \
          " --disable-docs" \
          " --prefix=#{install_dir}/embedded", env: env
  make "-j #{workers} SUBDIRS=src" # Skipping tests
  make "install SUBDIRS=src"
end
