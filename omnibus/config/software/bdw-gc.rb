name "bdw-gc"
default_version "8.0.4"
skip_transitive_dependency_licensing true

source :url => "https://github.com/ivmai/bdwgc/releases/download/v#{version}/gc-#{version}.tar.gz"

version "7.4.10" do
  source md5: "6d894c05c218aa380cd13f54f9c715e9"
end

version "7.6.8" do
  source md5: "9ae6251493ead5d0d13b044954cec7d7"
end

version "7.6.12" do
  source md5: "8175e1be00c6cd6eac2e8d67bdf451df"
end

version "8.0.4" do
  source md5: "67a5093e2f9f381bd550aa891d00b54b"
end

dependency "libatomic_ops"

relative_path "gc-#{version}"

env = with_standard_compiler_flags(with_embedded_path)
sysroot = "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk"
env["CFLAGS"] << " -fPIC -arch arm64 -arch x86_64 -isysroot #{sysroot} -isystem #{sysroot} "
env["CPPFLAGS"] = env["CPPFLAGS"].gsub("-arch arm64 -arch x86_64", "")

build do
  patch source: 'feature-thread-stackbottom-upstream.patch', plevel: 1

  command "./configure" \
          " --disable-debug" \
          " --disable-dependency-tracking" \
          " --disable-shared" \
          " --enable-large-config" \
          " --prefix=#{install_dir}/embedded", env: env


  make "-j #{workers}"
  make "install"
end
