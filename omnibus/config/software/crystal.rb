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

dependency "pcre2"
dependency "bdw-gc"
dependency "llvm_bin" unless FIRST_RUN
dependency "libevent"
dependency "libffi"

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
  env["CRYSTAL_PATH"] = "lib:/private/var/cache/omnibus/src/crystal/src"
else
  env["CRYSTAL_PATH"] = "lib:#{project_dir}/src"
end

build do
  command "git checkout #{CRYSTAL_SHA1}", cwd: project_dir

  mkdir "#{project_dir}/deps"
  make "deps", env: env
  mkdir ".build"
  command "echo #{Dir.pwd}", env: env

  crflags = "--no-debug"

  copy "#{Dir.pwd}/crystal-#{ohai['os']}-#{ohai['kernel']['machine']}/embedded/bin/crystal", ".build/crystal"

  # Compile for Intel
  command "make crystal stats=true release=true target=x86_64-apple-darwin FLAGS=\"#{crflags}\" CRYSTAL_CONFIG_LIBRARY_PATH= O=#{output_path}", env: env
  move output_bin, "#{output_bin}_x86_64"
  block { raise "Could not build crystal x86_64" unless File.exist?("#{output_bin}_x86_64") }

  # Clean up
  make "clean_cache clean", env: env

  # Restore x86_64 compiler w/ cross-compile support
  mkdir ".build"
  copy "#{output_bin}_x86_64", ".build/crystal"

  make "deps", env: env

  crtarget = "arm64-apple-macosx#{ENV["MACOSX_DEPLOYMENT_TARGET"]}"
  make "crystal stats=true release=true target=#{crtarget} FLAGS=\"#{crflags}\" CRYSTAL_CONFIG_TARGET=#{crtarget} CRYSTAL_CONFIG_LIBRARY_PATH= O=#{output_path}", env: env

  command "clang #{output_path}/crystal.o -o #{output_bin}_arm64 -target #{crtarget} src/llvm/ext/llvm_ext.o `llvm-config --libs --system-libs --ldflags 2>/dev/null` -lstdc++ -lpcre2-8 -lgc -lpthread -levent -liconv -ldl -v", env: env
  delete "#{output_path}/crystal.o"
  block { raise "Could not build crystal arm64" unless File.exist?("#{output_bin}_arm64") }

  # Lipo them up
  command "lipo -create -output #{output_bin} #{output_bin}_x86_64 #{output_bin}_arm64"
  delete "#{output_bin}_x86_64"
  delete "#{output_bin}_arm64"

  block do
    raise "Could not build crystal" unless File.exist?(output_bin)

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
