FROM debian@sha256:96e65f809d753e35c54b7ba33e59d92e53acc8eb8b57bf1ccece73b99700b3b0
# latest debian:bullseye-slim as of 2022-01-07

RUN dpkg --add-architecture i386 \
  && apt-get update && apt-get install -y \
  ca-certificates=20210119 \
  lib32gcc-s1=10.2.1-6 \
  libcurl4:i386=7.74.0-1.3+deb11u1 \
  libsdl2-2.0-0:i386=2.0.14+dfsg2-3 \
  && rm -rf /var/lib/apt/lists/*
