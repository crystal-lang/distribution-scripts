SHARDS_VERSION = "0.14.1"

name "shards"
default_version SHARDS_VERSION
skip_transitive_dependency_licensing true

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

version "0.11.1" do
  source md5: "6924888dffc158e2e1a10f8ec9c65cb0"
end

version "0.12.0" do
  source md5: "c65327561cfbb0c465ec4bd945423fe9"
end

version "0.13.0" do
  source md5: "a66b767ad9914472c23e1cb76446fead"
end

version "0.14.1" do
  source md5: "d7bdd10bb096b71428b06fc93097b3cc"
end

source url: "https://github.com/crystal-lang/shards/archive/v#{version}.tar.gz"

relative_path "shards-#{version}"
env = with_standard_compiler_flags(with_embedded_path(
  "LIBRARY_PATH" => "#{install_dir}/embedded/lib",
  "CRYSTAL_LIBRARY_PATH" => "#{install_dir}/embedded/lib"
))
env["CFLAGS"] << " -fPIC -arch arm64 -arch x86_64"
env["CPPFLAGS"] = env["CPPFLAGS"].gsub("-arch arm64 -arch x86_64", "")

build do
  crflags = "--no-debug --release"

  # Build for Intel
  make "bin/shards SHARDS=false CRYSTAL=#{install_dir}/bin/crystal FLAGS='#{crflags}'", env: env
  command "mv bin/shards bin/shards_x86_64"

  # Clean
  make "clean", env: env

  # Build for ARM64
  crflags += " --cross-compile --target aarch64-apple-darwin"
  make "bin/shards SHARDS=false CRYSTAL=#{install_dir}/bin/crystal FLAGS='#{crflags}'", env: env
  command "clang bin/shards.o -o bin/shards_arm64 -target aarch64-apple-darwin -L#{install_dir}/embedded/lib -lyaml -lpcre -lgc -lpthread -levent -liconv -ldl", env: env

  # Lipo them up
  command "lipo -create -output bin/shards bin/shards_x86_64 bin/shards_arm64"

  copy "bin/shards", "#{install_dir}/embedded/bin/shards"
end
