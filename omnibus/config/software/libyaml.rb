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

name "libyaml"
default_version '0.1.6'
skip_transitive_dependency_licensing true

# The sources of pyyaml are republished in S3 since pyyaml.org
# seems to be restricting the user agent or the requests from our CI
# http://pyyaml.org/download/libyaml/yaml-#{version}.tar.gz

source url: "http://crystal-lang.s3.amazonaws.com/libyaml/yaml-#{version}.tar.gz",
       md5: '5fe00cda18ca5daeb43762b80c38e06e'

relative_path "yaml-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)
  sysroot = "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk"
  env["CFLAGS"] << " -fPIC -arch arm64 -arch x86_64 -isysroot #{sysroot} -isystem #{sysroot} "
  env["CPPFLAGS"] = env["CPPFLAGS"].gsub("-arch arm64 -arch x86_64", "")

  command "./configure" \
          " --disable-shared" \
          " --prefix=#{install_dir}/embedded", env: env

  make "-j #{workers}", env: env
  make "-j #{workers} install", env: env
end
