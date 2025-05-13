#!/bin/bash -ue

bazel run @counterstrikesource-server//:image_tarball
docker run --rm -t -p 27015/udp -u 1000 counterstrikesource-server:bazel -- $@

# docker run --rm -it -p 27015/udp -u 1000 --entrypoint /bin/bash counterstrikesource-server:bazel
