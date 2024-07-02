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
  block { puts "\n=== Starting a build phase for crystal ===\n\n" }

  command "git checkout '#{CRYSTAL_SHA1}'", cwd: project_dir

  # Native crystal binary with cross-platform functionality
  block { puts "\n=== Build crystal's deps in #{project_dir}\n\n" }

  mkdir "#{project_dir}/deps"
  make "deps", env: env.dup
  mkdir ".build"

  block { puts "\n=== Build native crystal bin with embedded universal crystal binary\n\n" }
  copy "#{Dir.pwd}/crystal-#{ohai['os']}-x86_64/embedded/bin/crystal", ".build/crystal"
  command ".build/crystal --version", env: env.dup
  command "file .build/crystal", env: env.dup

  crflags = "--no-debug"
  command "make crystal stats=true release=true FLAGS=\"#{crflags}\" CRYSTAL_CONFIG_LIBRARY_PATH= O=#{output_path}", env: env.dup
  block "Testing the result file" do
    puts "===> Testing the result file #{output_bin}"
    raise "Could not build native crystal binary: #{output_bin}" unless File.exist?("#{output_bin}")
  end
  command "file #{output_bin}", env: env.dup
  command "#{output_bin} --version", env: env.dup

  make "clean_cache clean", env: env

  # Restore compiler w/ cross-compile support
  block { puts "\n\n=== Restore compiler with cross-compile support ===\n\n" }
  move "#{output_bin}", ".build/crystal"

  # x86_64 crystal binary
  block { puts "\n\n=== Building x86_64 binary ===\n\n" }

  original_CXXFLAGS_env = env["CXXFLAGS"].dup
  original_LDFLAGS_env = env["LDFLAGS"].dup

  env["CXXFLAGS"] = original_CXXFLAGS_env + " -target x86_64-apple-darwin"
  env["LDFLAGS"] = original_LDFLAGS_env + " -v -target x86_64-apple-darwin"
  env["LDLIBS"] = "-v -target x86_64-apple-darwin"
  make "deps", env: env.dup

  make "crystal verbose=true stats=true release=true target=x86_64-apple-darwin CRYSTAL_CONFIG_TARGET=x86_64-apple-darwin FLAGS=\"#{crflags}\" CRYSTAL_CONFIG_LIBRARY_PATH= O=#{output_path}", env: env
  command "clang #{output_path}/crystal.o -o #{output_bin}_x86_64 -target x86_64-apple-darwin src/llvm/ext/llvm_ext.o `llvm-config --libs --system-libs --ldflags 2>/dev/null` -lstdc++ -lpcre2-8 -lgc -lpthread -levent -liconv -ldl -v", env: env
  block "Testing the result file" do
    puts "===> Testing the result file #{output_bin}_x86_64"
    raise "Could not build crystal x86_64" unless File.exist?("#{output_bin}_x86_64")
  end
  # NOTE: Add validation of the output
  command "file #{output_bin}_x86_64", env: env

  # Clean up
  make "clean_cache clean", env: env

  # arm64 crystal binary
  block { puts "\n\n=== Building arm64 version ===\n\n" }

  # Compile for ARM64. Apple's clang only understands arm64, LLVM uses aarch64,
  # so we need to sub out aarch64 in our calls to Apple tools
  env["CXXFLAGS"] = original_CXXFLAGS_env + " -target arm64-apple-darwin"
  make "deps", env: env

  make "crystal stats=true release=true target=aarch64-apple-darwin FLAGS=\"#{crflags}\" CRYSTAL_CONFIG_TARGET=aarch64-apple-darwin CRYSTAL_CONFIG_LIBRARY_PATH= O=#{output_path}", env: env
  command "clang #{output_path}/crystal.o -o #{output_bin}_arm64 -target arm64-apple-darwin src/llvm/ext/llvm_ext.o `llvm-config --libs --system-libs --ldflags 2>/dev/null` -lstdc++ -lpcre2-8 -lgc -lpthread -levent -liconv -ldl -v", env: env

  block "Testing the result file" do
    puts "===> Testing the result file #{output_bin}_arm64"
    raise "Could not build crystal arm64" unless File.exist?("#{output_bin}_arm64")
  end
  # NOTE: Add validation of the output
  command "file #{output_bin}_arm64", env: env
  delete "#{output_path}/crystal.o"

  # Lipo them up
  block { puts "\n\n=== Combine x86_64 and arm64 binaries in single universal binary ===\n\n" }
  command "lipo -create -output #{output_bin} #{output_bin}_x86_64 #{output_bin}_arm64"

  # Clean up
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
