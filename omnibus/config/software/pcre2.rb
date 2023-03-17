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

name "pcre2"
default_version "10.42"
skip_transitive_dependency_licensing true

source url: "https://github.com/PCRE2Project/pcre2/releases/download/pcre2-#{version}/pcre2-#{version}.tar.gz",
       md5: "37d2f77cfd411a3ddf1c64e1d72e43f7"

relative_path "pcre2-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)
  env["CFLAGS"] << " -DMAC_OS_X_VERSION_MIN_REQUIRED=110000 -fPIC -arch arm64 -arch x86_64"
  env["CPPFLAGS"] = env["CPPFLAGS"].gsub("-arch arm64 -arch x86_64", "")

  command "./configure" \
          " --prefix=#{install_dir}/embedded" \
          " --disable-cpp" \
          " --disable-shared" \
          " --enable-unicode-properties" \
          " --enable-utf" \
          " --enable-jit", env: env

  make "-j #{workers}", env: env
  make "install", env: env
end
