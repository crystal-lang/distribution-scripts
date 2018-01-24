name 'libuv'
maintainer 'Juan Wajnerman'
homepage 'http://libuv.org/'

install_dir '/opt/libuv'
build_version do
  source :version, from_dependency: 'libuv'
end
build_iteration 1

dependency 'libuv'
dependency 'tgz_package' if mac_os_x? || centos?

exclude '\.git*'
exclude 'bundler\/git'
