"""The base system's layers, in the order the image stacks them.

A list rather than a filegroup because buildifier sorts a rule's `srcs` and
image layers are order-dependent: later layers overwrite earlier ones. Nothing
in this list overlaps today, but a formatter is the wrong thing to be deciding
that.
"""

BASE_LAYERS = [
    "@trixie//libc6:data",
    "@trixie//libgcc-s1:data",
    "@trixie//libstdc++6:data",
    "@trixie//zlib1g:data",
    "//base:base_files_layer",
    "//base:cacerts_layer",
]
