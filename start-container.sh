#!/bin/bash

CMD=docker

${CMD} --version 2>/dev/null
if ! [ $? == 0 ]; then
    CMD=podman
fi

${CMD} --version 2>/dev/null
if ! [ $? == 0 ]; then
    echo 'docker/podman not found'
    exit 1
fi

${CMD} rm -f nginx-ssl
${CMD} rmi -f nginx-ssl:latest
${CMD} build -t nginx-ssl:latest docker/.
${CMD} run -d \
    --name nginx-ssl \
    -p 9999:443 \
    -p 9998:80 \
    -v $(pwd)/nginx:/etc/nginx/conf.d:ro \
    -v $(pwd)/ssl:/ssl \
    nginx-ssl
