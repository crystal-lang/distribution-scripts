ARG debian_image
FROM ${debian_image} AS debian

RUN apt-get update \
 && apt-get install -y curl build-essential git automake libtool pkg-config

ENV CFLAGS="-fPIC -pipe ${release:+-O2}"

# build libpcre
FROM debian AS libpcre
ARG libpcre_version
RUN curl -L https://sourceforge.net/projects/pcre/files/pcre/${libpcre_version}/pcre-${libpcre_version}.tar.gz/download | tar -zx \
 && cd pcre-${libpcre_version} \
 && ./configure --disable-shared --disable-cpp --enable-jit --enable-utf --enable-unicode-properties \
 && make -j$(nproc)

# build libevent

FROM debian AS libevent
ARG libevent_version
RUN git clone https://github.com/libevent/libevent \
 && cd libevent \
 && git checkout ${libevent_version} \
 && ./autogen.sh \
 && ./configure --disable-shared --disable-openssl \
 && make -j$(nproc)

FROM debian
ARG crystal_version
ARG package_iteration
ARG libpcre_version
ARG libevent_version

RUN mkdir -p /output/lib/crystal/lib/

# Copy libraries
COPY --from=libpcre pcre-${libpcre_version}/.libs/libpcre.a /output/lib/crystal/lib/
COPY --from=libevent libevent/.libs/libevent.a libevent/.libs/libevent_pthreads.a /output/lib/crystal/lib/

# Create tarball
RUN mv /output /crystal-${crystal_version}-${package_iteration} \
 && mkdir /output \
 && tar -cvf /output/bundled-libs.tar /crystal-${crystal_version}-${package_iteration}
