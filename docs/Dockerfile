FROM debian:8 AS debian

RUN apt-get update \
 && apt-get install -y build-essential libevent-dev libpcre3-dev pkg-config git software-properties-common apt-transport-https curl \
 && (pkg-config || true)

RUN add-apt-repository "deb http://apt.llvm.org/jessie/ llvm-toolchain-jessie-4.0 main" \
 && curl -sSL https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - \
 && apt-get update \
 && apt-get install -y llvm-4.0-dev

ARG previous_crystal_release
ADD ${previous_crystal_release} /tmp/crystal.tar.gz
ENV PATH=${PATH}:/tmp/crystal/bin

RUN mkdir -p /tmp/crystal \
 && tar xz -f /tmp/crystal.tar.gz -C /tmp/crystal --strip-component=1 \
 && crystal --version

ARG output_docs_base_name
ARG crystal_sha1
RUN git clone https://github.com/crystal-lang/crystal \
 && cd crystal \
 && git checkout ${crystal_sha1} \
 \
 && make crystal docs \
 && git describe --tags --long --always 2>/dev/null > ./docs/revision.txt \
 && mv ./docs ./${output_docs_base_name} \
 \
 && mkdir -p /output \
 && tar -zcvf /output/${output_docs_base_name}.tar.gz ./${output_docs_base_name}
