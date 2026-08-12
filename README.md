# LAN of DOOM Counter-Strike: Source Server
Docker image for a private, preconfigured private Counter-Strike: Source server
as used by the LAN of DOOM.

# Installation
Run ``docker pull ghcr.io/lanofdoom/counterstrikesource-server:latest``

# Installed Addons
* LAN of DOOM Authenticate by Steam Group
* LAN of DOOM Disable Buyzones
* LAN of DOOM Disable Radar
* LAN of DOOM Disable Round Timer
* LAN of DOOM Free For All
* LAN of DOOM Free For All Spawns
* LAN of DOOM GunGame
* LAN of DOOM Map Settings
* LAN of DOOM Max Cash
* LAN of DOOM Paintball
* LAN of DOOM Remove Objectives
* LAN of DOOM Respawn
* LAN of DOOM Spawn Protection
* MetaMod:Source
* SourceMod

# Configuration
There is no entrypoint script and no environment variables. The image runs
``srcds_linux`` directly, so it is configured the same way the binary is: with
command line arguments and with config files.

The image's ``entrypoint`` carries the arguments the image insists on
(``-game cstrike``, ``-strictbindport``, ``-usercon``, ``+ip 0.0.0.0``). Its
``cmd`` carries the defaults a deployment is expected to replace, which is what
Kubernetes substitutes when a pod spec sets ``args:``:

```yaml
args: ["+map", "de_nuke", "+hostname", "\"LAN of DOOM\"", "+sv_password", "hunter2"]
```

Convar values containing spaces must carry their own quotes, as above: the
engine re-joins ``argv`` into one string and tokenizes it itself, so shell or
YAML quoting alone gets the value as far as ``argv`` and no further.

Config files are read from ``/opt/game/cstrike/cfg``; mount a ConfigMap or
Secret over a file there to override it, e.g. ``server.cfg``, or
``/opt/game/cstrike/motd.txt`` for the MOTD.

# Development
Build the image and load it into the local Docker daemon:

```sh
bazel run //:image_tarball
```

Run the test suite. The tests start the real image in a container and query it
over the same A2S protocol the Steam server browser uses, so they need a working
Docker daemon:

```sh
bazel test //...
```

The image has no base image: its Debian userland is assembled in ``base/`` from
the packages installed by the ``apt.install`` call in ``MODULE.bazel``, which
pins the Debian archive to a snapshot date via the accompanying
``apt.sources_list`` calls. Nothing bumps that date automatically, so picking
up newer packages means editing the snapshot URLs in ``MODULE.bazel``.

There is no pinned C++ toolchain: the MetaMod and SourceMod addons are built
with whatever toolchain the build already has, and it is the image's userland
that is kept new enough to load them rather than the compiler that is kept old
enough for the image. The comment above the ``apt`` calls in ``MODULE.bazel``
explains the constraint that puts on the snapshot date.
