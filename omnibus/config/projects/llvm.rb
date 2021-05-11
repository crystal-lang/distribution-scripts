name 'llvm'
maintainer 'Juan Wajnerman'
homepage 'http://llvm.org/'

install_dir '/opt/llvm'
build_version do
  source :version, from_dependency: 'llvm'
end
build_iteration 2

def valid_cmake_version?
  `cmake --version` =~ /cmake version (\d+\.)(\d+\.)(\d)/
  major, minor, patch = $1.to_i, $2.to_i, $3.to_i
  (major > 3) || (major == 3 && minor > 4) || (major == 3 && minor == 4 && patch >= 3)
rescue
  false
end

dependency 'cmake' unless valid_cmake_version?
dependency 'llvm'
dependency 'tgz_package' if macos? || mac_os_x? || centos?

exclude '\.git*'
exclude 'bundler\/git'
