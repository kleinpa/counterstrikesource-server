#!/bin/bash -ue

bazel run @counterstrikesource-server//:image_tarball
docker run --rm -it -p 27015/udp -u 1000 counterstrikesource-server:bazel -- $@
