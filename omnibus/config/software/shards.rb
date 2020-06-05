SHARDS_VERSION = "0.11.0"

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

version "0.8.1" do
  source md5: "f5b5108d798b1d86d2b9b45c3a2b5293"
end

version "0.10.0" do
  source md5: "f982f2dc0c796763205bd0de68e9f87e"
end

version "0.11.0" do
  source md5: "a16d6580411152956363a766e1517c9d"
end

source url: "https://github.com/crystal-lang/shards/archive/v#{version}.tar.gz"

relative_path "shards-#{version}"
env = with_standard_compiler_flags(with_embedded_path)

build do
  command "#{Dir.pwd}/shards-#{ohai['os']}-#{ohai['kernel']['machine']} install --production", env: env

  command "#{install_dir}/bin/crystal" \
          " build" \
          " -o #{install_dir}/embedded/bin/shards" \
          " src/shards.cr" \
          " --no-debug" \
          " --release ", env: env
end
