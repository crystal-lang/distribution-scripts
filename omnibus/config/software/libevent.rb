name "libevent"
default_version "2.1.8"
skip_transitive_dependency_licensing true

source url: "https://github.com/libevent/libevent/archive/release-#{version}-stable.tar.gz",
       md5: "80f8652e4b08d2ec86a5f5eb46b74510"

relative_path "libevent-release-#{version}-stable"
env = with_standard_compiler_flags(with_embedded_path)
sysroot = "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk"
env["CFLAGS"] << " -fPIC -arch arm64 -arch x86_64 -isysroot #{sysroot} -isystem #{sysroot} "
env["CPPFLAGS"] = env["CPPFLAGS"].gsub("-arch arm64 -arch x86_64", "")

build do
  command "./autogen.sh"
  command "./configure" \
          " --disable-dependency-tracking" \
          " --disable-shared" \
          " --disable-clock-gettime" \
          " --disable-openssl" \
          " --prefix=#{install_dir}/embedded", env: env
  make "-j #{workers}", env: env
  make  "install"
end
