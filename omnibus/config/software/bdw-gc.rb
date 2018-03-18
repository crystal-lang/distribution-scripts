name "bdw-gc"
default_version "7.4.10"

source :url => "https://github.com/ivmai/bdwgc/releases/download/v#{version}/gc-#{version}.tar.gz",
       :md5 => "6d894c05c218aa380cd13f54f9c715e9"

dependency "libatomic_ops"

relative_path "gc-#{version}"

env = with_standard_compiler_flags(with_embedded_path)
env["CFLAGS"] << " -fPIC"

build do
  command "./configure" \
          " --disable-debug" \
          " --disable-dependency-tracking" \
          " --disable-shared" \
          " --enable-large-config" \
          " --prefix=#{install_dir}/embedded", env: env


  make "-j #{workers}"
  make "install"
end
