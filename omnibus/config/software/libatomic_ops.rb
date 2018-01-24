name "libatomic_ops"
default_version "7.4.2"

source :url => "http://www.ivmaisoft.com/_bin/atomic_ops/libatomic_ops-7.4.2.tar.gz",
       :md5 => "1d6538604b314d2fccdf86915e5c0857"

relative_path 'libatomic_ops-7.4.2'

env = with_standard_compiler_flags
env["CFLAGS"] << " -fPIC"

build do
  command "./configure" \
          " --disable-dependency-tracking" \
          " --prefix=#{install_dir}/embedded", env: env
  make "-j #{workers}"
  make "install"
end
