#
# Copyright 2012-2014 Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

name "zlib"
default_version "1.2.8"
license "Zlib"
license_file "README"
skip_transitive_dependency_licensing true

version "1.2.6" do
  source sha256: "21235e08552e6feba09ea5e8d750805b3391c62fb81c71a235c0044dc7a8a61b"
end

version "1.2.8" do
  source sha256: "36658cb768a54c1d4dec43c3116c27ed893e88b02ecfcb44f2166f9c0b7f2a0d"
end

source url: "https://zlib.net/fossils/zlib-#{version}.tar.gz"

relative_path "zlib-#{version}"

build do
  # We omit the omnibus path here because it breaks mac_os_x builds by picking
  # up the embedded libtool instead of the system libtool which the zlib
  # configure script cannot handle.
  env = with_standard_compiler_flags
  env["CFLAGS"] << " -fPIC -arch arm64 -arch x86_64"
  env["CPPFLAGS"] = env["CPPFLAGS"].gsub("-arch arm64 -arch x86_64", "")

  # For some reason zlib needs this flag on solaris (cargocult warning?)
  env['CFLAGS'] << " -DNO_VIZ" if solaris2?

  command "./configure" \
          " --static" \
          " --prefix=#{install_dir}/embedded", env: env

  make "-j #{workers}", env: env
  make "-j #{workers} install", env: env
end
