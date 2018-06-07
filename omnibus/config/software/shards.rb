SHARDS_VERSION = "0.8.0"

name "shards"
default_version SHARDS_VERSION

dependency "crystal"
dependency "libyaml"

version "0.7.2" do
  source md5: "4f1f1e860ed1846fce01581ce9e6e7ad"
end

version "0.8.0" do
  source md5: "f0a52e64537ea6267a2006195e818c4d"
end

source url: "https://github.com/crystal-lang/shards/archive/v#{version}.tar.gz"

relative_path "shards-#{version}"
env = with_standard_compiler_flags(with_embedded_path)

build do
  command "#{install_dir}/bin/crystal" \
          " build" \
          " -o #{install_dir}/embedded/bin/shards" \
          " src/shards.cr" \
          " --no-debug" \
          " --release ", env: env
end
