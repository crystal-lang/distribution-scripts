name "llvm"
LLVM_VERSION = (ENV['LLVM_VERSION'] || "15.0.7").strip
default_version LLVM_VERSION
skip_transitive_dependency_licensing true

version "3.9.1" do
  source url: "http://releases.llvm.org/#{version}/llvm-#{version}.src.tar.xz",
         md5: "3259018a7437e157f3642df80f1983ea"
end

version "6.0.1" do
  source url: "http://releases.llvm.org/#{version}/llvm-#{version}.src.tar.xz",
         md5: "c88c98709300ce2c285391f387fecce0"
end

version "10.0.0" do
  source url: "https://github.com/llvm/llvm-project/releases/download/llvmorg-#{version}/llvm-#{version}.src.tar.xz",
         md5: "693cefdc49d618f828144486a18b473f"
end

version "15.0.7" do
  source url: "https://github.com/llvm/llvm-project/releases/download/llvmorg-#{version}/llvm-project-#{version}.src.tar.xz",
         md5: "bac436dbd5d37e38d3da75b03629053c"
end

if version == "15.0.7"
  # This is bringing the whole project because flags weren't sufficient to prevent certain parts from being fetched by the build system.
  relative_path "llvm-project-#{version}.src/llvm"
else
  relative_path "llvm-#{version}.src"
end

whitelist_file "lib/BugpointPasses.dylib"
whitelist_file "lib/libLTO.dylib"
whitelist_file "lib/LLVMHello.dylib"
whitelist_file "lib/libRemarks.dylib"

env = with_standard_compiler_flags(with_embedded_path)

llvm_build_dir = "#{project_dir}/build-llvm"

build do
  mkdir llvm_build_dir
  command "cmake" \
    " -DCMAKE_BUILD_TYPE=MinSizeRel" \
    " -DCMAKE_OSX_ARCHITECTURES=\"arm64;x86_64\"" \
    " -DLLVM_TARGETS_TO_BUILD=\"X86;AArch64\"" \
    " -DLLVM_ENABLE_TERMINFO=OFF" \
    " -DLLVM_ENABLE_FFI=OFF" \
    " -DLLVM_ENABLE_ZLIB=OFF" \
    " -DLLVM_BUILD_DOCS=OFF" \
    " -DLLVM_INCLUDE_DOCS=OFF" \
    " -DLLVM_BINARY_DIR=#{install_dir}" \
    " -DBUILD_SHARED_LIBS=OFF" \
    " -DLLVM_OPTIMIZED_TABLEGEN=ON" \
    " -DLLVM_ENABLE_ASSERTIONS=ON" \
    " -DLLVM_INCLUDE_TESTS=OFF" \
    " -DLLVM_ENABLE_Z3_SOLVER=OFF" \
    " -DLLVM_ENABLE_LIBXML2=OFF" \
    " -DLLVM_BUILD_BENCHMARKS=OFF" \
    " -DLLVM_INCLUDE_BENCHMARKS=OFF" \
    " -DLLVM_ENABLE_ZSTD=OFF" \
    "#{' -DPYTHON_EXECUTABLE=$(which python2.7)' if centos? }"\
    " #{project_dir}", env: env, cwd: llvm_build_dir
  command "cmake --build .", env: env, cwd: llvm_build_dir
  command "cmake -DCMAKE_INSTALL_PREFIX=#{install_dir} -P cmake_install.cmake", env: env, cwd: llvm_build_dir
  command "cmake --build . --target install", env: env, cwd: llvm_build_dir
end
