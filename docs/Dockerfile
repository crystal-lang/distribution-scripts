ARG crystal_docker_image
FROM ${crystal_docker_image}

RUN crystal --version

ARG output_docs_base_name
ARG crystal_sha1
RUN git clone https://github.com/crystal-lang/crystal \
 && cd crystal \
 && git checkout ${crystal_sha1} \
 \
 && make docs DOCS_OPTIONS='--json-config-url=/api/versions.json  --canonical-base-url="https://crystal-lang.org/api/latest/"'\
 && git describe --tags --long --always 2>/dev/null > ./docs/revision.txt \
 && mv ./docs ./${output_docs_base_name} \
 \
 && mkdir -p /output \
 && tar -zcvf /output/${output_docs_base_name}.tar.gz ./${output_docs_base_name} \
 && scripts/docs-versions.sh > /output/versions.json
