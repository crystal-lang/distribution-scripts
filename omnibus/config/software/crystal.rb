CRYSTAL_VERSION = ENV['CRYSTAL_VERSION']
CRYSTAL_SHA1 = ENV['CRYSTAL_SHA1']
FIRST_RUN = ENV["FIRST_RUN"]
CRYSTAL_SRC = (ENV['CRYSTAL_SRC'] || "").strip

name "crystal"
default_version CRYSTAL_VERSION
skip_transitive_dependency_licensing true

if CRYSTAL_SRC.empty?
  source git: "https://github.com/crystal-lang/crystal"
else
  source git: CRYSTAL_SRC
end

dependency "pcre"
dependency "bdw-gc"
dependency "llvm_bin" unless FIRST_RUN
dependency "libevent"

env = with_standard_compiler_flags(with_embedded_path(
  "LIBRARY_PATH" => "#{install_dir}/embedded/lib",
  "CRYSTAL_LIBRARY_PATH" => "#{install_dir}/embedded/lib",
))
env["CFLAGS"] << " -fPIC -arch arm64 -arch x86_64"
env["CPPFLAGS"] = env["CPPFLAGS"].gsub("-arch arm64 -arch x86_64", "")

unless FIRST_RUN
  llvm_bin = Omnibus::Software.load(project, "llvm_bin", nil)
end

output_path = "#{install_dir}/embedded/bin"
output_bin = "#{output_path}/crystal"

if FIRST_RUN
  env["PATH"] = "#{project_dir}/deps:#{env["PATH"]}"
else
  env["PATH"] = "#{llvm_bin.project_dir}/bin:#{project_dir}/deps:#{env["PATH"]}"
end

if macos? || mac_os_x?
  env["CRYSTAL_PATH"] = "/private/var/cache/omnibus/src/crystal/src"
else
  env["CRYSTAL_PATH"] = "#{project_dir}/src"
end

build do
  command "git checkout #{CRYSTAL_SHA1}", cwd: project_dir

  mkdir "#{project_dir}/deps"
  command "make deps", env: env
  command "mkdir .build", env: env
  command "echo #{Dir.pwd}", env: env

  crflags = "--no-debug"

  command "cp #{Dir.pwd}/crystal-#{ohai['os']}-#{ohai['kernel']['machine']}/embedded/bin/crystal .build/crystal", env: env

  # Compile for Intel
  command "make crystal stats=true release=true FLAGS=\"#{crflags}\" CRYSTAL_CONFIG_LIBRARY_PATH= O=#{output_path}", env: env
  command "mv #{output_bin} #{output_bin}_x86_64"

  # Clean up
  command "make clean"

  # Compile for ARM64
  env["CXXFLAGS"] << ' -target aarch64-apple-darwin'
  command "make deps", env: env
  command "mkdir .build", env: env
  command "echo #{Dir.pwd}", env: env

  crflags += " --cross-compile --target aarch64-apple-darwin -Dwithout_openssl -Dwithout_zlib --release --stats"
  command "CRYSTAL_CONFIG_LIBRARY_PATH= bin/crystal build src/compiler/crystal.cr #{crflags}", env: env
  command "clang crystal.o -o #{output_bin}_arm64 -target aarch64-apple-darwin src/llvm/ext/llvm_ext.o `llvm-config --libs --system-libs 2>/dev/null` -lstdc++ -lpcre -lgc -lpthread -levent -liconv -ldl", env: env

  # Lipo them up
  command "lipo -create -output #{output_bin} #{output_bin}_x86_64 #{output_bin}_arm64"
  command "rm #{output_bin}_x86_64 #{output_bin}_arm64"

  block do
    raise "Could not build crystal" unless File.exists?(output_bin)

    if macos? || mac_os_x?
      otool_libs = `otool -L #{output_bin}`
      if otool_libs.include?("/usr/local/lib") || otool_libs.include?('/opt/homebrew/lib')
        raise "Found local libraries linked to the generated compiler:\n#{otool_libs}"
      end
    end
  end

  sync "#{project_dir}/src", "#{install_dir}/src"
  sync "#{project_dir}/etc", "#{install_dir}/etc"
  sync "#{project_dir}/samples", "#{install_dir}/samples"
  mkdir "#{install_dir}/bin"

  erb source: "crystal.erb",
      dest: "#{install_dir}/bin/crystal",
      mode: 0755,
      vars: { install_dir: install_dir }
end
