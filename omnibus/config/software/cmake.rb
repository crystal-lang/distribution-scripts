name "cmake"
default_version "3.8.2"

source :url => "https://cmake.org/files/v3.8/cmake-3.8.2.tar.gz",
       :md5 => "b5dff61f6a7f1305271ab3f6ae261419"

relative_path "cmake-#{version}"

env = with_standard_compiler_flags(with_embedded_path)

build do
  command "./bootstrap"
  make "-j #{workers}", env: env
  make "install"
end
