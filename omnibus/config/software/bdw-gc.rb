name "bdw-gc"
default_version "7.4.2"

source :url => "http://www.hboehm.info/gc/gc_source/gc-#{version}.tar.gz",
       :md5 => "12c05fd2811d989341d8c6d81f66af87"

dependency "libatomic_ops"

relative_path "gc-#{version}"

env = with_standard_compiler_flags(with_embedded_path)
env["CFLAGS"] << " -fPIC"

build do
  command "./configure" \
          " --disable-debug" \
          " --disable-dependency-tracking" \
          " --disable-shared" \
          " --prefix=#{install_dir}/embedded", env: env


  make "-j #{workers}"
  make "install"
end
