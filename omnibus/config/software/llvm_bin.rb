name "llvm_bin"
LLVM_VERSION = (ENV['LLVM_VERSION'] || "10.0.0").strip
default_version "#{LLVM_VERSION}-2"
skip_transitive_dependency_licensing true

if linux?
  case LLVM_VERSION
  when "3.9.1"
    if _64_bit?
      source_md5 = "cedaa626e3959b5ab467467e6dfb91fe"
    else
      source_md5 = "8b847e903163054196d3854122363b8b"
    end
  else
    raise "llvm_bin #{LLVM_VERSION} not supported on linux"
  end
elsif (macos? || mac_os_x?) && _64_bit?
  case LLVM_VERSION
  when "3.9.1"
    source_md5 = "9fb52b6a648e700f431b459586eb5403"
  when "6.0.1"
    source_md5 = "435beaff5e309921f4d87c275cad4e03"
  when "10.0.0"
    # source_md5 = "edccfa777cba6e160b19bd5b57b12c8f" # 10.0.0-1
    source_md5 = "dc44dbc947b67c76e44df1c9e38df901" # 10.0.0-2
  else
    raise "llvm_bin #{LLVM_VERSION} not supported on osx"
  end
end

source url: "http://crystal-lang.s3.amazonaws.com/llvm/llvm-#{version}-#{ohai['os']}-#{ohai['kernel']['machine']}.tar.gz",
       md5: source_md5

relative_path "llvm-#{version}"
