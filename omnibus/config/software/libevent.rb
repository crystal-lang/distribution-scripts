name "libevent"
default_version "2.1.8"

source url: "https://github.com/libevent/libevent/archive/release-#{version}-stable.tar.gz",
       md5: "80f8652e4b08d2ec86a5f5eb46b74510"

relative_path "libevent-release-#{version}-stable"
env = with_standard_compiler_flags(with_embedded_path)
env["CFLAGS"] << " -fPIC"
env["CFLAGS"] << " -I/usr/local/opt/openssl/include" if mac_os_x?
env["LDFLAGS"] << " -L/usr/local/opt/openssl/lib" if mac_os_x?

build do
  command "./autogen.sh"
  command "./configure" \
          " --disable-dependency-tracking" \
          " --disable-shared" \
          " --disable-clock-gettime" \
          " --prefix=#{install_dir}/embedded", env: env
  make "-j #{workers}", env: env
  make  "install"
end
