name "llvm_bin"
LLVM_VERSION = (ENV['LLVM_VERSION'] || "15.0.7").strip
default_version "#{LLVM_VERSION}-3"
skip_transitive_dependency_licensing true

if (macos? || mac_os_x?) && _64_bit?
  case LLVM_VERSION
  when "10.0.0"
    # source_md5 = "edccfa777cba6e160b19bd5b57b12c8f" # 10.0.0-1
    # source_md5 = "dc44dbc947b67c76e44df1c9e38df901" # 10.0.0-2
    source_md5 = "d32c4d28b8fc50efda3f451e0d8265ea" # 10.0.0-3 (universal darwin)
  when "15.0.7"
    source_md5 = "0ab0ffe63a0e72346a979d7a0e964b94" # 15.0.7-3 (universal darwin)
  else
    raise "llvm_bin #{LLVM_VERSION} not supported on osx"
  end
else
  raise "llvm_bin not supported"
end

platform = ohai['os']
# Currently, it is considered `universal` based on the alterations made in the commit 'ed5f1f97e0a67157d886dd6675902e35199a1ab3'
arch = "x86_64"

source url: "http://crystal-lang.s3.amazonaws.com/llvm/llvm-#{version}-#{platform}-#{arch}.tar.gz",
       md5: source_md5

relative_path "llvm-#{version}"
