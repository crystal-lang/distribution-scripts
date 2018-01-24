name "libuv"
default_version "1.2.1"

source url: "https://github.com/libuv/libuv/archive/v#{version}.tar.gz",
       md5: "11df46d4d1ce6c4c5ec87024320ca9ff"

relative_path "libuv-#{version}"
env = with_standard_compiler_flags(with_embedded_path)
env["CFLAGS"] << " -fPIC"

build do
  command "sh autogen.sh"
  command "./configure" \
          " --prefix=#{install_dir}"
  make "-j #{workers}", env: env
  make  "install"
end
