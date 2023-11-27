FROM debian:11 AS debian

RUN apt-get update \
 && apt-get install -y curl build-essential git automake libtool pkg-config

ENV CFLAGS="-fPIC -pipe ${release:+-O2}"

# build libpcre2
FROM debian AS libpcre2
ARG libpcre2_version=10.42
RUN curl -L https://github.com/PCRE2Project/pcre2/releases/download/pcre2-${libpcre2_version}/pcre2-${libpcre2_version}.tar.gz | tar -zx \
 && cd pcre2-${libpcre2_version} \
 && ./configure --disable-shared --disable-cpp --enable-jit --enable-utf --enable-unicode-properties \
 && make -j$(nproc)

# build libevent

FROM debian AS libevent
ARG libevent_version=release-2.1.12-stable
RUN git clone https://github.com/libevent/libevent \
 && cd libevent \
 && git checkout ${libevent_version} \
 && ./autogen.sh \
 && ./configure --disable-shared --disable-openssl \
 && make -j$(nproc)

FROM debian AS crystal
COPY --from=crystal_base . /crystal
RUN ls /crystal
RUN mkdir /output && tar -xf /crystal/crystal-${crystal_version}-*.tar -C /output

FROM scratch
ARG crystal_version=dev
ARG package_version=1
COPY --from=crystal /output /
COPY --from=libpcre2 pcre2-*/.libs/libpcre2-8.a /crystal-${crystal_version}-${package_version}/lib/crystal/
COPY --from=libevent libevent/.libs/libevent.a libevent/.libs/libevent_pthreads.a /crystal-${crystal_version}-${package_version}/lib/crystal/
