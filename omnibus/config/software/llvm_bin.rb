name "llvm_bin"
default_version "3.9.1-1"

if linux?
  if _64_bit?
    source_md5 = "cedaa626e3959b5ab467467e6dfb91fe"
  else
    source_md5 = "8b847e903163054196d3854122363b8b"
  end
elsif mac_os_x? && _64_bit?
  source_md5 = "9fb52b6a648e700f431b459586eb5403"
end

source url: "http://crystal-lang.s3.amazonaws.com/llvm/llvm-#{version}-#{ohai['os']}-#{ohai['kernel']['machine']}.tar.gz",
       md5: source_md5

relative_path "llvm-#{version}"
