name "libatomic_ops"
default_version "7.4.10"

source :url => "https://github.com/ivmai/libatomic_ops/releases/download/v#{version}/libatomic_ops-#{version}.tar.gz",
       :md5 => "47dcc36e1f77ab0efdee5d99888b3ffe"

relative_path "libatomic_ops-#{version}"

env = with_standard_compiler_flags
env["CFLAGS"] << " -fPIC"

build do
  command "./configure" \
          " --disable-dependency-tracking" \
          " --prefix=#{install_dir}/embedded", env: env
  make "-j #{workers}"
  make "install"
end
