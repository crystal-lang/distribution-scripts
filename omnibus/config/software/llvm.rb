name "llvm"
LLVM_VERSION = (ENV['LLVM_VERSION'] || "10.0.0").strip
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

relative_path "llvm-#{version}.src"

whitelist_file "lib/BugpointPasses.dylib"
whitelist_file "lib/libLTO.dylib"
whitelist_file "lib/LLVMHello.dylib"
whitelist_file "lib/libRemarks.dylib"

env = with_standard_compiler_flags(with_embedded_path)

llvm_build_dir = "#{build_dir}/build-llvm"

build do
  mkdir llvm_build_dir
  command "cmake" \
    " -DCMAKE_BUILD_TYPE=MinSizeRel" \
    " -DLLVM_TARGETS_TO_BUILD=X86" \
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
    "#{' -DPYTHON_EXECUTABLE=$(which python2.7)' if centos? }"\
    " #{project_dir}", env: env, cwd: llvm_build_dir
  command "cmake --build .", env: env, cwd: llvm_build_dir
  command "cmake -DCMAKE_INSTALL_PREFIX=#{install_dir} -P cmake_install.cmake", env: env, cwd: llvm_build_dir
  command "cmake --build . --target install", env: env, cwd: llvm_build_dir
end
