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

name "pcre"
default_version "8.40"
skip_transitive_dependency_licensing true

source url: "https://ftp.pcre.org/pub/pcre/pcre-#{version}.tar.gz",
       md5: "890c808122bd90f398e6bc40ec862102"

relative_path "pcre-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)
  sysroot = "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk"
  env["CFLAGS"] << " -fPIC -arch arm64 -arch x86_64 -isysroot #{sysroot} -isystem #{sysroot} "
  env["CPPFLAGS"] = env["CPPFLAGS"].gsub("-arch arm64 -arch x86_64", "")

  command "./configure" \
          " --prefix=#{install_dir}/embedded" \
          " --disable-shared" \
          " --enable-unicode-properties" \
          " --enable-utf8", env: env

  make "-j #{workers}", env: env
  make "install", env: env
end
