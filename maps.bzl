"""Assembles the maps repository's checkout into the archive mapcycle_file and the maps layer expect.

counterstrikesource-maps groups files by map (e.g. `aim_deagle7k/maps/aim_deagle7k.bsp`,
`aim_deagle7k/LICENSE`), one directory per map. Its own build.sh drops each map's
README.md/LICENSE and merges the rest flat into a single tree -- `maps/`, `materials/`,
`sound/`, etc. all at the archive root -- before taring it up. maps_archive() reproduces
that merge so the fetched checkout can stand in for the release tarball that used to
fill `@maps//file`.
"""

load("@bazel_skylib//lib:paths.bzl", "paths")
load("@rules_pkg//:pkg.bzl", "pkg_tar")
load("@rules_pkg//pkg:mappings.bzl", "pkg_files", "strip_prefix")

_EXCLUDED_FILENAMES = ["README.md", "LICENSE"]

def _maps_flatten_impl(ctx):
    staged_files = []
    for f in ctx.files.srcs:
        # short_path for a file in an external repo is "../<repo>/<map dir>/<rest>";
        # the map dir groups files by map but is not part of the game's directory
        # layout, so it is dropped along with the leading "../<repo>/".
        rest = f.short_path.split("/")[3:]
        if len(rest) < 2 or rest[-1] in _EXCLUDED_FILENAMES:
            continue
        staged = ctx.actions.declare_file(paths.join(ctx.label.name, *rest))
        ctx.actions.symlink(output = staged, target_file = f)
        staged_files.append(staged)
    return [DefaultInfo(files = depset(staged_files))]

_maps_flatten = rule(
    implementation = _maps_flatten_impl,
    doc = "Flattens a counterstrikesource-maps checkout into a single tree, one file per action.",
    attrs = {
        "srcs": attr.label_list(
            allow_files = True,
            mandatory = True,
            doc = "Files from a counterstrikesource-maps checkout, one directory per map.",
        ),
    },
)

def maps_archive(name, srcs, **kwargs):
    """Packages a counterstrikesource-maps checkout into a single flattened tar.gz.

    Args:
        name: name of the resulting pkg_tar target.
        srcs: files from a counterstrikesource-maps checkout, one directory per map.
        **kwargs: passed through to the underlying pkg_tar.
    """
    flattened = name + "_flattened"
    _maps_flatten(
        name = flattened,
        srcs = srcs,
    )

    # pkg_tar's own strip_prefix matches against the generated file's raw
    # exec path, which for a target defined in an external repo (as this one
    # always is) still carries the "external/<repo>/" segment and never
    # matches, silently leaving paths unstripped. Routing through pkg_files
    # instead resolves the strip against each file's owning-target package,
    # which is external-repo aware, before pkg_tar packages the result.
    files = name + "_files"
    pkg_files(
        name = files,
        srcs = [":" + flattened],
        strip_prefix = strip_prefix.from_pkg(flattened),
    )
    pkg_tar(
        name = name,
        srcs = [":" + files],
        extension = "tar.gz",
        **kwargs
    )
