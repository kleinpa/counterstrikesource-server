#!/bin/bash -ue

bazel run @counterstrikesource-server//:image_tarball
docker run --rm -it --init -p 27015:27015/udp -u 1000 counterstrikesource-server:bazel -- -game cstrike -strictbindport -usercon -tickrate 100 +ip 0.0.0.0 +map "de_dust2" $@

# docker run --rm -it -p 27015/udp -u 1000 --entrypoint /bin/bash counterstrikesource-server:bazel
