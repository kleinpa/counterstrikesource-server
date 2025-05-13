#!/bin/bash -ue
cd $(dirname $0)

bazel run @rules_steam//generate -- --app 232330 --repo counterstrikesource_dedicated --out $(pwd)/steamapps.bzl
bazel mod deps
